# StructuredQueries

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/StructuredQueries.jl.svg?branch=master)](https://travis-ci.org/davidagold/StructuredQueries.jl)
[![codecov](https://codecov.io/gh/davidagold/StructuredQueries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/StructuredQueries.jl)


StructuredQueries provides a generic framework for data manipulation in Julia.

You can install this package by calling
```
julia> Pkg.add("StructuredQueries")
```
This package supports Julia 0.5.

## Objectives

The present package aims to provide a querying framework that is

* Generic -- the framework should be able to support multiple backends.

* Modular -- the framework should encourage modularity of collection machinery.

* Extensible -- the framework should be easily extensible to represent (relatively) arbitrary manipulations.

* Ergonomic -- the framework should allow users to express their intentions easily.

These desiderata are interrelated -- especially the first three. For instance, modularity of collection machinery allows the latter to be re-used in support for different data backends, thereby supporting generality as well.

For examples of how these objectives are achieved in practice, please take a look at the [Tables](https://github.com/davidagold/Tables.jl)/[AbstractTables](https://github.com/davidagold/AbstractTables.jl) demonstrations.

## `Query{S}`

Central to the StructuredQueries package are the `Query{S}` data type and the `@query` macro for creating `Query`s. A `Query{S}` wraps a `source` field of type `S` and a `graph` field of linked `QueryNode` leaf subtype objects. The graph represents the flow of data through the manipulation verbs invoked by the user in the creation of the respective `Query`. The user can materialize a `Query` as a tabular data structure by means of `collect`.

The present package provides a basic scaffolding for `collect` machinery but does not implement support for any specific backend (e.g. `DataFrame`s or SQL database connections). Rather, packages that offer data types amenable to querying logic can extend `collect` in an appropriate manner. For instance, we demonstrate how to develop [a generic collection interface](https://github.com/davidagold/AbstractTables.jl/tree/master/src/column_indexable/query) for data types that satisfy the AbstractTables [column-indexable interface](https://github.com/davidagold/AbstractTables.jl#column-indexable-interface). Data types such as `Table` that satisfy these interfaces are then automatically furnished with the ability to collect `Query`s against `Table` sources:

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
StructuredQueries.Query{Tables.Table}

julia> collect(qry)
Tables.Table
│ Row │ name    │
├─────┼─────────┤
│ 1   │ "Niamh" │
│ 2   │ "Roger" │
```
