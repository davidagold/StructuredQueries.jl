# StructuredQueries

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/StructuredQueries.jl.svg?branch=master)](https://travis-ci.org/davidagold/StructuredQueries.jl)
[![codecov](https://codecov.io/gh/davidagold/StructuredQueries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/StructuredQueries.jl)


StructuredQueries provides a generic framework for data manipulation in Julia.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/StructuredQueries.jl.git")
```

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

## Dummy sources

A `Query` object has two fields: a `source` and a `graph`. The `source` is the data source against which the `Query` is to be collected. On the other hand, the `graph` only contains information about the manipulation commands invoked within the context of the `@query` call and is entirely agnostic as to the type of the data source being queried. The present package exposes this backend agnosticism by means of "dummy source" functionality. A user can prepend the name of a data source within an `@query` invocation with `:` to designate it as a dummy source:

```julia
julia> qry = @query filter(:src, A > .5) |>
           select(B)
Query with dummy source src
```
One must then specify an *actual* data source by means of a keyword argument when `collect`ing the `Query`:
```julia
julia> tbl1 = Tables.Table(
           A = [1, 2, 3, 4],
           B = [4, 5, 6, 7]
       )
Tables.Table
│ Row │ A │ B │
├─────┼───┼───┤
│ 1   │ 1 │ 4 │
│ 2   │ 2 │ 5 │
│ 3   │ 3 │ 6 │
│ 4   │ 4 │ 7 │

julia> collect(qry, src = tbl1)
Tables.Table
│ Row │ B │
├─────┼───┤
│ 1   │ 4 │
│ 2   │ 5 │
│ 3   │ 6 │
│ 4   │ 7 │
```

Note that the keyword must match the name of dummy source as specified in the original query:

```julia
julia> collect(qry, source = tbl1)
ERROR: ArgumentError: Undefined source: source. Check spelling in query.
 in #collect#5(::Array{Any,1}, ::Function, ::StructuredQueries.Query{Symbol}) at /Users/David/.julia/v0.5/StructuredQueries/src/collect.jl:22
 in (::Base.#kw##collect)(::Array{Any,1}, ::Base.#collect, ::StructuredQueries.Query{Symbol}) at ./<missing>:0
```

The upshot of this functionality is that one may `collect` the same `Query` against multiple backends:

```julia
julia> tbl2 = Table(
           A = rand(4),
           B = rand(4)
       )
Tables.Table
│ Row │ A        │ B        │
├─────┼──────────┼──────────┤
│ 1   │ 0.414642 │ 0.753482 │
│ 2   │ 0.795449 │ 0.144824 │
│ 3   │ 0.769256 │ 0.415009 │
│ 4   │ 0.837353 │ 0.96585  │

julia> collect(qry, src = tbl2)
Tables.Table
│ Row │ B        │
├─────┼──────────┤
│ 1   │ 0.144824 │
│ 2   │ 0.415009 │
│ 3   │ 0.96585  │
```

That is, the `Query` framework provided by the present package is intended to be generic not only in the sense that the same `@query` invocation can be used multiple times to query different data sources, but also that the same `Query` object produced by a single `@query` invocation can be used to query different data sources.
