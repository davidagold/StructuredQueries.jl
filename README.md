# jplyr

[![Build Status](https://travis-ci.org/davidagold/jplyr.jl.svg?branch=master)](https://travis-ci.org/davidagold/jplyr.jl)

`jplyr` (working name) is a data manipulation library for Julia. Like its namesake -- Hadley Wickham's [dplyr](https://github.com/hadley/dplyr) -- jplyr aims to provide fast and ergonomic data manipulation "verbs" (rather, macros) for various Julia data source objects, e.g. `DataFrame`s and database connections.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/jplyr.jl.git")
```

### Details

The strategy for `jplyr` facilities is to produce and "run" graphs consisting of linked `QueryNode` objects that represent data flow through manipulation commands. A complete graph stores information about the type of the data source and about the manipulations to be applied. Running the graph involves (will involve) generating code specific to these details.

For instance, consider the `@filter` macro. Using an empty surrogate `DataFrame` type for illustration purposes, we can see how `@filter` produces a "plan" for executing a query against such a `DataFrame`:

```julia
julia> using jplyr

julia> iris = DataFrame()
jplyr.DataFrame()

julia> @filter(iris, PetalLength > 1.5, Species == "setosa")
jplyr.FilterNode(jplyr.DataNode{jplyr.DataFrame}(jplyr.DataFrame()),Expr[:(PetalLength > 1.5),:(Species == "setosa")])

julia> dump(ans)
jplyr.FilterNode
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
```
In words, the command `@filter(iris, PetalLength > 1.5, Species == "setosa")` produces a `FilterNode` object whose `input` field is a `DataNode` object that wraps the data source and whose `conds` field is a vector of the predicates by which we desire to filter the data. Such a `FilterNode` object can (in theory) then be `run` to produce code that actually queries the original data source.

In fact, a call to a single such macro does run the resultant `FilterNode` object: 
```julia
julia> macroexpand(:( @filter(iris, PetalLength > 1.5, Species == "setosa") ))
quote  # /Users/David/.julia/v0.5/jplyr/src/filter.jl, line 5:
    (jplyr.run)((jplyr.filter)(iris,jplyr.QueryArg{Expr}[jplyr.QueryArg{Expr}(:(PetalLength > 1.5)),jplyr.QueryArg{Expr}(:(Species == "setosa"))]))
end
```
It's just that, currently, `run(x) = x`. 

To build up more complex graphs, one can use the `@query` macro:
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
The `@query` macro also supports piping for more readable syntax:
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
