# jplyr

[![Build Status](https://travis-ci.org/davidagold/jplyr.jl.svg?branch=master)](https://travis-ci.org/davidagold/jplyr.jl)

`jplyr` (working name) is a data manipulation library for Julia. Like its namesake -- Hadley Wickham's [dplyr](https://github.com/hadley/dplyr) -- jplyr aims to provide fast and ergonomic data manipulation "verbs" (rather, macros) for various Julia data source objects, e.g. `DataFrame`s and database connections.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/jplyr.jl.git")
```

### Implementation details

The strategy for `jplyr` facilities is to produce and "run" graphs consisting of linked `QueryNode` objects that represent the flow of data through manipulation commands such as `@select` and `@filter`. The graph is produced at macroexpand-time and hence does not contain any information about the type of the data source. Rather, the graph (and any other information/objects that may be appropriate) are passed to a `run` method spliced into the call-site of the original command. `run` then in turn dispatches on the type of the data source.

The details of the `@filter` macro are a good reflection of this package's general strategy. Suppose we've loaded the `iris` dataset
```julia
using DataFrames
using RDatasets
using jplyr
iris = dataset("datasets", "iris")
```
which we want to filter by some criteria based on the `PetalLength` and `Species` fields. To do so, we use the `@filter` macro:
```julia
julia> @filter(iris, PetalLength > 1.5, Species == "setosa")
13×5 DataFrames.DataFrame
│ Row │ SepalLength │ SepalWidth │ PetalLength │ PetalWidth │ Species  │
├─────┼─────────────┼────────────┼─────────────┼────────────┼──────────┤
│ 1   │ 5.4         │ 3.9        │ 1.7         │ 0.4        │ "setosa" │
│ 2   │ 4.8         │ 3.4        │ 1.6         │ 0.2        │ "setosa" │
│ 3   │ 5.7         │ 3.8        │ 1.7         │ 0.3        │ "setosa" │
│ 4   │ 5.4         │ 3.4        │ 1.7         │ 0.2        │ "setosa" │
│ 5   │ 5.1         │ 3.3        │ 1.7         │ 0.5        │ "setosa" │
│ 6   │ 4.8         │ 3.4        │ 1.9         │ 0.2        │ "setosa" │
│ 7   │ 5.0         │ 3.0        │ 1.6         │ 0.2        │ "setosa" │
│ 8   │ 5.0         │ 3.4        │ 1.6         │ 0.4        │ "setosa" │
│ 9   │ 4.7         │ 3.2        │ 1.6         │ 0.2        │ "setosa" │
│ 10  │ 4.8         │ 3.1        │ 1.6         │ 0.2        │ "setosa" │
│ 11  │ 5.0         │ 3.5        │ 1.6         │ 0.6        │ "setosa" │
│ 12  │ 5.1         │ 3.8        │ 1.9         │ 0.4        │ "setosa" │
│ 13  │ 5.1         │ 3.8        │ 1.6         │ 0.2        │ "setosa" │
```
To see how this works, let's take a look at the implementation (from [here](https://github.com/davidagold/jplyr.jl/blob/be40192449b142c0a538afcf364551b89a06313e/src/filter.jl#L1)) of the `@filter` method used above:
```julia
macro filter(input::Symbol, conds::Expr...)
    g = _filter(input, collect(conds))
    f, fdef, fields = resolve(g)
    #= we need to generate the filtering kernel's definition at macroexpand-time
    so it can be spliced into the proper (i.e., original caller's) scope =#
    return quote
        $f = $fdef
        run($(esc(input)), $g, $f, $fields)
    end
end
```
First, the `@filter` creates a graph `g` to represent the command called by the user. We can see what this looks like for ourselves:
```julia
julia> g = jplyr._filter(:iris, [:(PetalLength > 1.5), :(Species == "setosa")])
jplyr.FilterNode(jplyr.DataNode(:iris),Expr[:(PetalLength > 1.5),:(Species == "setosa")])

julia> dump(ans)
jplyr.FilterNode
  input: jplyr.DataNode
    input: Symbol iris
  conds: Array{Expr}((2,))
    1: Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol >
        2: Symbol PetalLength
        3: Float64 1.5
      typ: Any
    2: Expr
      head: Symbol call
      args: Array{Any}((3,))
        1: Symbol ==
        2: Symbol Species
        3: String
          data: Array{UInt8}((6,)) UInt8[0x73,0x65,0x74,0x6f,0x73,0x61]
      typ: Any
```
(The graph is of course not very complicated since we are considering only a single command. Below, we'll see that the `query` macro can be used to build up more complex manipulation graphs.) 

The strategy for filtering a `DataFrame` object is to create a "filter kernel" function that can then be `bitbroadcast`ed over the relevant columns. In this case, we would like to `bitbroadcast` the kernel `(x, y) -> x > 1.5 & y == "setosa"` over the columns `iris[:PetalLength], iris[:Species]`. The (admittedly vaguely named) `resolve` function generates a `gensym`ed name for such a kernel, the kernel's definition (as an `Expr` object), and a `Set` of the names of the columns to be passed to the kernel:
```julia
julia> jplyr.resolve(g)
(Symbol("##f#473"),:((PetalLength,Species)->(PetalLength > 1.5) & (Species == "setosa")),Set(Symbol[:PetalLength,:Species]))
```
Finally, a definition of the kernel (bound to a `gensym`ed name) and a call to `run(iris, ##f#473, g, Set(Symbol[:PetalLength,:Species]))` are spliced into the original call site of `@filter`. The `run` method dispatches on the type of `iris`, sees that it's a `DataFrame`, and hence employs the `bitbroadcast` strategy noted above. If `iris` were a database connection of some sort, `run` could instead (and will in the future) generate SQL code based on `g`.

It is possible to pipe arguments to `@filter` using the standard pipe operator `|>`:
```julia
julia> iris |> @filter(SepalLength > 5.5, Species == "setosa")
3×5 DataFrames.DataFrame
│ Row │ SepalLength │ SepalWidth │ PetalLength │ PetalWidth │ Species  │
├─────┼─────────────┼────────────┼─────────────┼────────────┼──────────┤
│ 1   │ 5.8         │ 4.0        │ 1.2         │ 0.2        │ "setosa" │
│ 2   │ 5.7         │ 4.4        │ 1.5         │ 0.4        │ "setosa" │
│ 3   │ 5.7         │ 3.8        │ 1.7         │ 0.3        │ "setosa" │
```

The strategy is essentially the same as above: `@filter` generates a graph representing the manipulation and splices in a kernel definition and `run` call into the original `@filter` call site. However, since `@filter` does not have access to the data source, (i.e., `iris`), the call to `run` only passes the graph, the kernel and the field names. `run` dispatches on these objects and returns an anonymous function `x -> run(x, g, kernel, fieldnames)`, which then receives the data source `iris` from the pipe operator. 

There is support for an `@select` macro, too:
```julia
julia> iris |>
           @filter(SepalLength > 5.5, Species == "setosa") |>
           @select(PetalWidth)
3×1 DataFrames.DataFrame
│ Row │ PetalWidth │
├─────┼────────────┤
│ 1   │ 0.2        │
│ 2   │ 0.4        │
│ 3   │ 0.3        │
```
However, because of technical difficulties, it only supports receiving a data source via `|>`.


One can use the `@query` macro to build up more complex graphs, which `run` will eventually support:
```julia
julia> @query select(filter(iris, PetalLength > 1.5, Species == "setosa"), SepalLength)
jplyr.SelectNode(jplyr.FilterNode(jplyr.DataNode{jplyr.DataFrame}(jplyr.DataFrame()),Expr[:(PetalLength > 1.5),:(Species == "setosa")]),Symbol[:SepalLength])

julia> dump(ans)
jplyr.SelectNode
  input: jplyr.FilterNode
    input: jplyr.DataNode{jplyr.DataFrame}
      data: jplyr.DataFrame jplyr.DataFrame()
    conds: Array{Expr}((2,))
      1: Expr
        head: Symbol call
        args: Array{Any}((3,))
          1: Symbol >
          2: Symbol PetalLength
          3: Float64 1.5
        typ: Any
      2: Expr
        head: Symbol call
        args: Array{Any}((3,))
          1: Symbol ==
          2: Symbol Species
          3: String
            data: Array{UInt8}((6,)) UInt8[0x73,0x65,0x74,0x6f,0x73,0x61]
        typ: Any
  cols: Array{Symbol}((1,))
    1: Symbol SepalLength
```
(Right now, `@query` just returns the graph itself and does not perform any manipulation.) Note above that manipulation commands within an `@query` call are not annotated with the `@` macro designation. `@query` also supports piping for more readable syntax:
```julia
julia> @query iris |>
           filter(PetalLength > 1.5, Species == "setosa") |>
           select(SepalLength)
jplyr.SelectNode(jplyr.FilterNode(jplyr.DataNode{jplyr.DataFrame}(jplyr.DataFrame()),Expr[:(PetalLength > 1.5),:(Species == "setosa")]),Symbol[:SepalLength])
```

### Extensibility

One of the goals of this package is to create a data manipulation regime that is at least somewhat extensible. One can imagine support for typical data sources such as `DataFrame`s and database connections. But users are free to hack whatever implementation of `run` for a manipulation graph based on a type of their own. For instance, one could also imagine a user defining an interface for use with the [DataStreams.jl](https://github.com/JuliaData/DataStreams.jl) and [CSV.jl](https://github.com/JuliaData/CSV.jl/blob/master/src/Source.jl) packages that would allow one to write
```julia
iris = CSV.Source("iris.csv")
qry = @query iris |>
  filter(PetalLength > 1.5, Species == "setosa") |>
  select(SepalLength)
Data.stream!(qry, CSV.Sink("iris1.csv"))
```
