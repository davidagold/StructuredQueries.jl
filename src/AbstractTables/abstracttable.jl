# TODO: Include discussion of null storage patterns
"""
`AbstractTable` interface minimal requirements:

`columns(tbl)` => `Vector{Any}`
`fields(tbl)` => `Vector{Symbol}`
`index(tbl)` => `Dict{Symbol, Int}`
`setindex!(...)` exclusive means of adding new columns
`empy(tbl)` return an empty table of the same type as `tbl`
`copy(tbl)` return a copy of `tbl`

The contents of `columns(tbl)[i]` must be iterable. The orderings of
columns(tbl) and fields(tbl) must be consistent -- that is, fields(tbl)[i] must
be the field name of columns(tbl)[i]. The mapping in `index(tbl)` must respect
the ordering of columns and fields in `columns(tbl)` and `fields(tbl)`. This
ordering is assumed to be the canonical column ordering for `tbl`.

Depending on their internals, user-defined concrete `T<:AbstractTable` types
may also wish to implement the following methods (though they are guaranteed by
the `AbstractTable` interface):

`getindex(tbl, fld)` return the column corresponding to field `fld`
`eachrow(tbl)` return an iterator over rows realized as tuples

We do not guarantee that the number of rows can be directly obtained. However,
the AbstractTable interface provides traits that can be used to communicate
patterns of column data storage. If, for a user-defined type `T<:AbstractTable`,
the number of rows can be directly accessed via `nrow(tbl::T)`, the user may
set

    `AbstractTables.tblrowdim(::T) = AbstractTable.HasRowDim()`

to communicate this fact to code-path selection mechanisms in methods that deal
generally with `AbstractTable`s.
"""
abstract AbstractTable

### Traits

abstract TableRowDim
immutable HasRowDim <: TableRowDim end
immutable RowDimUnknown <: TableRowDim end

tblrowdim(tbl::AbstractTable) = RowDimUnknown()
nrow(tbl::AbstractTable) = _nrow(tbl, tblrowdim(tbl))
_nrow(tbl, ::RowDimUnknown) = error()
_nrow(tbl, ::HasRowDim) = ncol(tbl) > 0 ? length(columns(tbl)[1]) : 0


"""
Returns the number of columns in an AbstractTable.
"""
ncol(tbl::AbstractTable) = length(columns(tbl))

"""
Returns the `eltype`s of the columns of an AbstractTable.
"""
eltypes(tbl::AbstractTable) = map(eltype, columns(tbl))
eltypes(tbl::AbstractTable, fields::Symbol...) =
    map(eltype, [ tbl[field] for field in fields ])

"""
Returns the number of dimensions of an AbstractTable.
"""
Base.ndims(::AbstractTable) = 2

### Iteration and enumeration

"""
"Enumerate" the columns of an AbstractTable by field (column name).

Arguments:

* tbl::AbstractTable

Returns:

* cols::Base.Zip2{Array{Symbol,1},Array{Any,1}}: An iterator over
`(field, column)` pairs from `tbl`.
"""
eachcol(tbl::AbstractTable) = zip(fields(tbl), columns(tbl))

"""
    `eachrow(tbl, [flds...])`

Return an iterator over the rows (materialized as `Tuple`s) of `tbl`. If `flds`
are specified, the tuples returned by the row iterator will contain data from
only the respective columns.
"""
eachrow(tbl::AbstractTable) = zip(columns(tbl)...)
function eachrow(tbl::AbstractTable, flds...)
    idx = index(tbl)
    cols = columns(tbl)
    return zip([ cols[idx[fld]] for fld in flds ]...)
end

### Indexing

"""
Arguments:

* tbl::AbstractTable

Returns:

* index::Dict{Symbol, Int}: a mapping from each field to its respective
canonical index

Notes: This default implementation is not efficient. Concrete types
`T <: AbstractTable` should implement their own versions.
"""
function index(tbl::AbstractTable)
    res = Dict{Symbol, Int}()
    for (j, fld) in enumerate(fields(tbl))
        res[fld] = j
    end
    return res
end

Base.getindex(tbl::AbstractTable, fld::Symbol) = columns(tbl)[index(tbl)[fld]]

# Other

function Base.isequal(tbl1::AbstractTable, tbl2::AbstractTable)
    isequal(ncol(tbl1), ncol(tbl2)) || return false
    isequal(tbl1.allowsnulls, tbl2.allowsnulls) || return false
    isequal(tbl1.hasnulls, tbl2.hasnulls) || return false
    for ((fld1, col1), (fld2, col2)) in zip(eachcol(tbl1), eachcol(tbl2))
        isequal(fld1, fld2) || return false
        isequal(col1, col2) || return false
    end
    return true
end

function Base.hash(tbl::AbstractTable)
    h = hash(tbl.allowsnulls) + 1
    h = hash(tbl.hasnulls) + 1
    for (i, (fld, col)) in enumerate(eachcol(tbl))
        h = hash(i, h)
        h = hash(fld, h)
        h = hash(tbl[fld], h)
    end
    return @compat UInt(h)
end
