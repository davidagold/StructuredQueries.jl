# StructuredQueries

*a generic query representation framework for Julia.*

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Build Status](https://travis-ci.org/davidagold/StructuredQueries.jl.svg?branch=master)](https://travis-ci.org/davidagold/StructuredQueries.jl)
[![StructuredQueries](http://pkg.julialang.org/badges/StructuredQueries_0.5.svg)](http://pkg.julialang.org/?pkg=StructuredQueries)
[![codecov](https://codecov.io/gh/davidagold/StructuredQueries.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/davidagold/StructuredQueries.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://davidagold.github.io/StructuredQueries.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://davidagold.github.io/StructuredQueries.jl/latest)


## Installation

StructuredQueries.jl is registered in [METADATA.jl](https://github.com/JuliaLang/METADATA.jl). Install it with

```
julia> Pkg.add("StructuredQueries")
```

This package supports Julia 0.5.


## Objectives

The present package aims to support a querying framework that is

* Generic -- the framework should be able to support multiple backends.

* Modular -- the framework should encourage modularity of collection machinery.

* Extensible -- the framework should be easily extensible to represent (relatively) arbitrary manipulations.

* Ergonomic -- the framework should allow users to express their intentions easily.


## Documentation

- [**STABLE**](https://davidagold.github.io/StructuredQueries.jl/stable) &mdash; **most recently tagged version of the documentation.**
- [**LATEST**](https://davidagold.github.io/StructuredQueries.jl/latest) &mdash; *in-development version of the documentation.*
