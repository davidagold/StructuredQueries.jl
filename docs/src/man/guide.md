# Guide

## Installation

StructuredQueries is a registered package. Install it with
```julia
Pkg.add("StructuredQueries")
```

This package supports Julia 0.5.

## Usage

StructuredQueries.jl provides a generic framework for data manipulation in Julia. The center of this framework are the `@query` and `@collect` macros.

To express a query in SQ, one uses the `@query` macro:

```
@query qry
```

where `qry` is Julia code that follows a certain structure that we will describe below.

`qry` is parsed according to what we'll call a *query context*. By a *context* we mean a general semantics for Julia code that may differ from the semantics of the standard Julia environment. That is to say: though `qry` must be valid Julia syntax, the code is not run as it would were it executed outside of the `@query` macro. Rather, code such as `qry` that occurs inside of a query context is subject to a number of transformations before it is run.

For instance, suppose `iris` names some tabular data source object (e.g. a `DataFrame`). We might express a query to produce a subset of the data that satisfies some predicate, say `sepal_length > 5.0` with

```
julia> q = @query filter(iris, sepal_length > 5.0)
Query against a source of type DataFrames.DataFrame
```

The structure of the query passed to `@query` consists of a *manipulation verb* (e.g. `filter`) that in turn takes a *data source argument* (e.g. `iris`) for its first argument and any number of *query arguments* (e.g. `sepal_length > 5.0`) for its latter arguments. These are the three different "parts" of a query: (1) data sources (or just "sources"), (2) manipulation verbs (or just "verbs"), and (3) query arguments.

The `@query` macro transforms the code `filter(iris, sepal_length > 5.0)` into code that produces a `Query` object that represents the structure of the query:

```
julia> typeof(q)
StructuredQueries.Query

julia> graph(q)
FilterNode
  arguments:
      1)  sepal_length > 5.0
  inputs:
      1)  DataNode
            source:  source of type DataFrame
```

## Natively Supported Verbs


!!! note
    By "natively supported", we mean that the following verbs are recognized by the `@query` macro and properly incorporated into a graph representation.

* `select`
* `filter`
* `groupby`
* `summarize`
* `orderby`
* `innerjoin`
* `leftjoin`
* `outerjoin`
* `crossjoin`


## Contexts

Each part of a query induces its own context in which code is evaluated. The most significant aspect of such contexts is name resolution. That is to say, names resolve differently depending on which part of a query they appear in and in what capacity they appear:

* In a data source specification context -- e.g., as the first argument to a verb such as `filter` above -- names are evaluated in the enclosing scope of the `@query` invocation. Thus, `iris` in the query used to define `q` above refers precisely to the `Table` object to which the name is bound in the top level of `Main`.

* Names of manipulation verbs are not resolved to objects but rather merely signal how to construct the graphical representation of the query. (Indeed, in what follows there is no such function `filter` that is ever invoked in the execution of a query involving a `filter` clause.)

* Names of functions called within a query argument context, such as `>` in `sepal_length > 5.0` are evaluated in the enclosing scope of the `@query` invocation.

* Names that appear as arguments to function calls within a query argument context, such as `sepal_length` in `sepal_length > 5.0` are not resolved to objects but are rather parsed as "attributes" of the data source (in this case, `iris`). When the data source is a tabular data structure, such attributes are taken to be column names, but such behavior is just a feature of a particular query semantics (see below in the section "Roadmap and open questions".) The attributes that are passed as arguments to a given function call in a query argument are stored as data in the graphical query representation.


## Composition

Manipulation verbs are composable in that an invocation of one verb may serve as a source argument to another verb:

```
julia> @query select(filter(iris, sepal_length > 5.0), species, petal_width)
Query against a source of type DataFrames.DataFrame

julia> graph(ans)
SelectNode
  arguments:
      1)  species
      2)  petal_width
  inputs:
      1)  FilterNode
            arguments:
                1)  sepal_length > 5.0
            inputs:
                1)  DataNode
                      source:  source of type DataFrame
```  

One can pipe arguments to verbs inside an `@query` context. For instance, the above `Query` is equivalent to that produced by

```
@query iris |>
    filter(sepal_length > 5.0) |>
    select(species, petal_width)
```

In this case, the first argument (i.e. `sepal_length > 5.0`) to the verb `filter` is not a data source argument (e.g. `iris`, which is instead the first argument to `|>`), but is rather a query argument.

If `q` is a `Query`, then invoking `@query q ...` simply extends the graph of `q` to include a representation of `...`:

```
julia> f(q::Query) = @query q |> groupby(species, petal_length > 5.0)
f (generic function with 1 method)

julia> f(@query filter(iris, sepal_length > 5.0))
Query against a source of type DataFrames.DataFrame

julia> graph(ans)
GroupbyNode
  arguments:
      1)  species
      2)  petal_length > 5.0
  inputs:
      1)  FilterNode
            arguments:
                1)  sepal_length > 5.0
            inputs:
                1)  DataNode
                      source:  source of type DataFrame
```

## Collection

!!! note
    StructuredQueries.jl does not provide any sort of collection machinery; it only provides a query representation interface. Support for backend-specific collection machineries can be found either in data type hosting packages (e.g. [`TablesDemo.jl`](https://github.com/davidagold/TablesDemo.jl)) or in a collection interface package (e.g. [`Collect.jl`](https://github.com/davidagold/Collect.jl))

To materialize the results of `q` as a concrete, in-memory Julia object, one calls

```
collect(q)
```
