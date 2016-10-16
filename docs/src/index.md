# StructuredQueries.jl

*A query representation framework for Julia.*

## Package Abstract

StructuredQueries.jl (SQ) provides an interface that produces graph representations of user-facing queries. These graphs are qrapped by `Query` objects. Given appropriate backend support ("collection machinery"), one can collect `Query`s against data sources by means of `Base.collect`.

A package that provides a queryable data type `T` can implement a respective collection machinery and re-export the SQ interface, thereby "embedding" the latter in `T`'s  essential API. An example of this "embedding approach" can be found in [AbstractTables.jl](@ref).

Or, a package might implement a collection machinery for a non-native but queryable data type `T` and re-export both the SQ and `T`'s interfaces. An example of this "interfacing approach" can be found in [Collect.jl](@ref).


## Manual Outline

```@contents
Pages = [
    "man/guide.md",
    "man/examples.md"
]
Depth = 1
```


## Library Outline

```@contents
Pages = [
    "lib/public.md",
    "lib/internals.md"
]
```
