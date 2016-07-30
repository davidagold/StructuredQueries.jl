"""
AbstractTable interface requirements:

`columns(tbl)` => `Vector{Any}`
`fields(tbl)` => `Vector{Symbol}`
`getindex(tbl, fld)` return the column corresponding to field `fld`
`setindex!(...)` exclusive means of adding new columns
`eachrow(tbl)` => ???

The orderings of columns(tbl) and fields(tbl) must be consistent -- that is,
fields(tbl)[i] must be the field name of columns(tbl)[i]. This ordering is
assumed to be the canonical column ordering.

We do not guarantee that the number of rows can be directly obtained. We do
require that a type `T <: AbstractTable` type implement an `eachrow(tbl::T)`
method that returns an iterator over the rows of `tbl`. It is not yet clear if
we ought to require that each row be returned as a specific type
(e.g. a `Tuple`) or allow that rows returned by iterating over `eachrow(tbl)`
be general iterators that allow numeric indexing (according to the canonical
ordering of `tbl`'s columns.)
"""
abstract AbstractTable

"""
Returns the number of columns in an AbstractTable.
"""
ncol(tbl::AbstractTable) = length(columns(tbl))

"""
Returns the `eltype`s of the columns of an AbstractTable.
"""
eltypes(tbl::AbstractTable) = map(eltype, columns(tbl))

"""
Returns the number of dimensions of an AbstractTable.
"""
Base.ndims(::AbstractTable) = 2

"""
"Enumerate" the columns of an AbstractTable by field name.

Arguments:

* tbl::AbstractTable

Returns:

* cols::Base.Zip2{Array{Symbol,1},Array{Any,1}}: An iterator over
`(field, column)` pairs from `tbl`.
"""
eachcol(tbl::AbstractTable) = zip(fields(tbl), columns(tbl))

"""
Arguments:

* tbl::AbstractTable

Returns:

* index::Dict{Symbol, Int}: a mapping from each field to its respective
canonical index
"""
function index(tbl::AbstractTable)
    res = Dict{Symbol, Int}()
    for (j, fld) in enumerate(fields)
        res[fld] = j
    end
    return res
end
