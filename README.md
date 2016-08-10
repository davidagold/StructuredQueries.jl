# jplyr

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/jplyr.jl.svg?branch=master)](https://travis-ci.org/davidagold/jplyr.jl)
[![codecov](https://codecov.io/gh/davidagold/jplyr.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/jplyr.jl)


`jplyr` (working name) is a data manipulation library for Julia. Like its namesake -- Hadley Wickham's [dplyr](https://github.com/hadley/dplyr) -- jplyr aims to provide fast and ergonomic data manipulation "verbs" (rather, macros) for various Julia data source objects, e.g. `DataFrame`s and database connections.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/jplyr.jl.git")
```

## Features

`jplyr` data manipulation facilities are currently being developed against an internal `Table` type and `AbstractTable` interface. It should be straightforward to extend these facilities to `DataFrame`s, once certain design decisions concerning the latter have been settled.

We defer a precise specification of the features this package provides until a time at which they are less in flux. The examples of the following sections should give the reader a sense of what sort of functionality to expect.

### `@query`

`@query` is the main command provided by `jplyr`. All specific data manipulation commands -- e.g. `select`, `filter`, etc. -- are used within the context of an `@query` call, which returns a graph consisting of linked `QueryNode` leaf subtype objects representing the flow of data through the invoked manipulation commands. To materialize the results of the query in a `Table`, the user calls `collect`:

```julia
julia> using jplyr

julia> tbl = Table(
           name = ["Niamh", "Roger", "Genevieve", "Aiden"],
           age = [27, 63, 26, 17],
           eye_color = ["green", "brown", "brown", "blue"]
       )
jplyr.AbstractTables.Table
│ Row │ name        │ age │ eye_color │
├─────┼─────────────┼─────┼───────────┤
│ 1   │ "Niamh"     │ 27  │ "green"   │
│ 2   │ "Roger"     │ 63  │ "brown"   │
│ 3   │ "Genevieve" │ 26  │ "brown"   │
│ 4   │ "Aiden"     │ 17  │ "blue"    │

julia> qry = @query select(tbl, name);

julia> typeof(qry)
jplyr.SelectNode

julia> collect(qry)
jplyr.AbstractTables.Table
│ Row │ name        │
├─────┼─────────────┤
│ 1   │ "Niamh"     │
│ 2   │ "Roger"     │
│ 3   │ "Genevieve" │
│ 4   │ "Aiden"     │
```
Manipulation commands within an `@query` call can be piped for readability:

```julia
julia> qry = @query tbl |>
           select(stmt = name * " is " * string(age) * " years old and has "
                  * eye_color * " eyes.");

julia> collect(qry)
jplyr.AbstractTables.Table
│ Row │ stmt                                            │
├─────┼─────────────────────────────────────────────────┤
│ 1   │ "Niamh is 27 years old and has green eyes."     │
│ 2   │ "Roger is 63 years old and has brown eyes."     │
│ 3   │ "Genevieve is 26 years old and has brown eyes." │
│ 4   │ "Aiden is 17 years old and has blue eyes."      │

```

###`@qcollect`

`@qcollect` ("query-collect") behaves precisely the same as `@query` except that it automatically `collect`s the resultant graph:

```julia
julia> tbl = Table(
           a = rand(50),
           b = rand(50)
       )
jplyr.AbstractTables.Table
│ Row │ a        │ b         │
├─────┼──────────┼───────────┤
│ 1   │ 0.115646 │ 0.918137  │
│ 2   │ 0.653013 │ 0.201968  │
│ 3   │ 0.752644 │ 0.699487  │
│ 4   │ 0.207182 │ 0.499927  │
│ 5   │ 0.250651 │ 0.682966  │
│ 6   │ 0.307979 │ 0.829877  │
│ 7   │ 0.542869 │ 0.0720994 │
│ 8   │ 0.631453 │ 0.519834  │
│ 9   │ 0.66113  │ 0.0764974 │
│ 10  │ 0.281846 │ 0.0502995 │
⋮
with 40 more rows.

julia> @qcollect tbl |>
           filter(a > b) |>
           summarize(small_b_avg = mean(b))
jplyr.AbstractTables.Table
│ Row │ small_b_avg │
├─────┼─────────────┤
│ 1   │ 0.358216    │
```


## Implementation details

These are in constant flux. We refer the interested reader to the [source code](https://github.com/davidagold/jplyr.jl/tree/master/src).

## Extensibility

One of the goals of this package is to create a data manipulation interface that is extensible. The user-facing query interface (which produces a manipulation graph) is separate from the graph execution interface. This means that one can immediately use the query interface to produce query graphs whose base `DataNode` wraps objects of arbitrary type `T`. The real work involves extending the execution interface to handle execution of each `QueryNode` leaf subtype against data sources of type `T`. In practice, this requires familiarizing oneself with the information stored in each such `QueryNode` subtype and leveraging it in the appropriately defined `_collect` method. In the following example we show how `_collect` may be overloaded to query vectors of simple structs:
```julia
julia> abstract Thing

julia> immutable Person <: Thing
           name::String
           age::Int
           eye_color::String
       end

julia> function jplyr._collect{T<:Thing}(A::Vector{T}, g::jplyr.SelectNode)
           res_tbl = Table()
           for field in g.args
               res_tbl[field] = [ getfield(thing, field) for thing in A ]
           end
           return res_tbl
       end

julia> people = Person[];

julia> push!(
           people,
           Person("Niamh", 27, "green"),
           Person("Roger", 63, "brown"),
           Person("Genevieve", 26, "brown"),
           Person("Aiden", 17, "blue")
       )
4-element Array{Person,1}:
 Person("Niamh",27,"green")    
 Person("Roger",63,"brown")    
 Person("Genevieve",26,"brown")
 Person("Aiden",17,"blue")     

julia> @qcollect people |>
           select(name, age)
jplyr.AbstractTables.Table
│ Row │ name        │ age │
├─────┼─────────────┼─────┤
│ 1   │ "Niamh"     │ 27  │
│ 2   │ "Roger"     │ 63  │
│ 3   │ "Genevieve" │ 26  │
│ 4   │ "Aiden"     │ 17  │

```
One can imagine other handy extensions of this interface. For instance, one could in principle define an interface for use with the [DataStreams.jl](https://github.com/JuliaData/DataStreams.jl) and [CSV.jl](https://github.com/JuliaData/CSV.jl) packages that would allow one to write
```julia
iris = CSV.Source("iris.csv")
qry = @query iris |>
    filter(PetalLength > 1.5, Species == "setosa") |>
    select(SepalLength)
Data.stream!(qry, CSV.Sink("iris1.csv"))
```
in order to manipulate the data in one CSV file and enter the result into another without having to create an intermediary object.
