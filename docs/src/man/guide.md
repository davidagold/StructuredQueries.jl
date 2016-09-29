# Guide

## Installation

StructuredQueries is a registered package. Install it with
```julia
Pkg.add("StructuredQueries")
```

This package supports Julia 0.5.

## Usage

StructuredQueries.jl provides a generic framework for data manipulation in Julia. The center of this framework is the `Query{S}` data type, which represents the structure of a query passed to the `@query` macro. The user can materialize a `Query` as a (tabular) data structure by means of `collect`.
