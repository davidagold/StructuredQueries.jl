# jplyr

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/jplyr.jl.svg?branch=master)](https://travis-ci.org/davidagold/jplyr.jl)
[![codecov](https://codecov.io/gh/davidagold/jplyr.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/jplyr.jl)


jplyr (working name) provides a generic framework for data manipulation in Julia.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/jplyr.jl.git")
```

## Objectives

The present package aims to provide a querying framework that is

* Generic -- the framework should be able to support multiple backends.

* Modular -- the framework should encourage modularity of collection machinery.

* Extensible -- the framework should be easily extensible to represent (relatively) arbitrary manipulations.

* Ergonomic -- the framework should allow users to express their intentions easily.

These desiderata are interrelated -- especially the first three. For instance, modularity of collection machinery allows the latter to be re-used in support for different data backends, thereby exhibiting generality as well.

For examples of how these objectives are achieved in practice, please take a look at the [Tables](https://github.com/davidagold/Tables.jl)/[AbstractTables](https://github.com/davidagold/AbstractTables.jl) demonstrations.

## `Query{S}`

Central to the jplyr package are the `Query{S}` data type and the `@query` macro for creating `Query`s. A `Query{S}` wraps a `source` field of type `S` and a `graph` field of linked `QueryNode` leaf subtype objects. The graph represents the flow of data through the manipulation verbs invoked by the user in the creation of the respective `Query`. `Query`s are materialized as tabular data structures by means of `collect`.

The provision of `collect` machinery is delegated to packages that provide data types amenable to querying logic whose structure is represented by `QueryNode` graphs. For instance, [a generic collection interface](https://github.com/davidagold/AbstractTables.jl/tree/master/src/column_indexable/query) is developed for data types that satisfy the AbstractTables [column-indexable interface](https://github.com/davidagold/AbstractTables.jl#column-indexable-interface). Data types such as `Table` that satisfy these interfaces are then automatically furnished with the ability to collect `Query`s against `Table` sources:

```julia
julia> using Tables

julia> tbl = Tables.Table(
               name = ["Niamh", "Roger", "Genevieve", "Aiden"],
               age = [27, 63, 26, 17],
               eye_color = ["green", "brown", "brown", "blue"]
           )
Tables.Table
│ Row │ name        │ age │ eye_color │
├─────┼─────────────┼─────┼───────────┤
│ 1   │ "Niamh"     │ 27  │ "green"   │
│ 2   │ "Roger"     │ 63  │ "brown"   │
│ 3   │ "Genevieve" │ 26  │ "brown"   │
│ 4   │ "Aiden"     │ 17  │ "blue"    │


julia> qry = @query tbl |>
           filter(age > 26) |>
           select(name)
Query with Tables.Table source

julia> typeof(qry)
jplyr.Query{Tables.Table}

julia> collect(qry)
Tables.Table
│ Row │ name    │
├─────┼─────────┤
│ 1   │ "Niamh" │
│ 2   │ "Roger" │
```
