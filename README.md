# jplyr

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/jplyr.jl.svg?branch=master)](https://travis-ci.org/davidagold/jplyr.jl)
[![codecov](https://codecov.io/gh/davidagold/jplyr.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/jplyr.jl)


`jplyr` (working name) is a data manipulation library for Julia. Like its namesake -- Hadley Wickham's [dplyr](https://github.com/hadley/dplyr) -- jplyr aims to provide fast and ergonomic data manipulation "verbs" (rather, macros) for various Julia data source objects, e.g. `DataFrame`s and database connections.

This package is currently under development and is not registered. You can obtain it for yourself by calling
```
julia> Pkg.clone("https://github.com/davidagold/jplyr.jl.git")
```

**NOTE [8/3/16]**: `jplyr` is currently under heavy development. Check back in a week or so for specifics on the following sections. 

## Features

### `@query`

### Implementation details

### Extensibility

One of the goals of this package is to create a data manipulation regime that is at least somewhat extensible. One can imagine support for typical data sources such as `DataFrame`s and database connections. But users are free to hack whatever implementation of `run` for a manipulation graph based on a type of their own. For instance, one could also imagine a user defining an interface for use with the [DataStreams.jl](https://github.com/JuliaData/DataStreams.jl) and [CSV.jl](https://github.com/JuliaData/CSV.jl/blob/master/src/Source.jl) packages that would allow one to write
```julia
iris = CSV.Source("iris.csv")
qry = @query iris |>
  filter(PetalLength > 1.5, Species == "setosa") |>
  select(SepalLength)
Data.stream!(qry, CSV.Sink("iris1.csv"))
```
