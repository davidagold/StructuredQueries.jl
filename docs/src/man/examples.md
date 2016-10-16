# Examples

The following packages are examples of how the StructuredQueries framework can be extended to support queries against particular backends.


## AbstractTables.jl

[AbstractTables.jl](https://github.com/davidagold/AbstractTables.jl) is an example of how the present query framework can be embedded in a particular data type's API. Concrete data types such as [`Table`]() that implement the [requisite interfaces](https://github.com/davidagold/AbstractTables.jl#interfaces) are in turn furnished with querying and collection facilities for free.


## Collect.jl

[Collect.jl](https://github.com/davidagold/Collect.jl) is an interface between StructuredQueries.jl and extant data types, such as [`DataFrame`](https://github.com/JuliaStats/DataFrames.jl), that do not directly extend the present query framework as part of their core API.
