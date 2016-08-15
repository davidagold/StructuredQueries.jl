"""
A tabular data type.

Fields:

* `index::Dict{Symbol, Int}`: A mapping from symbols to numeric column indices
* `columns::Vector{NullableVector}`: A vector of NullableVector columns
* `fields::Vector{Symbol}`: A vector of fields (column names)
<!-- * `allowsnulls::Vector{Bool}`: A vector of flags indicating whether the
respective column allows storage of null values -->
* `hasnulls::Vector{Bool}`: A vector of flags indicating whether the
respective column currently stores any null values

Notes: The ordering of the columns in `columns` respects that of the numeric
indices given by `index`.

<!-- If `allowsnulls[i] == false` then `hasnulls[i]` must also `== false`.

Columns are assumed to be either `Array` or `NullableArray` objects. If
`isa(columns[i], Array)` then `allowsnulls[i] == false`. -->

The types of columns are not coerced upon `Table` initialization.

`'.'` is not a valid character within a field. All instances of `'.'` will be
replaced by `'_'` upon constructing a `Table` or setting a column.
"""
type Table <: AbstractTable
    index::Dict{Symbol, Int}
    columns::Vector{NullableVector}
    fields::Vector{Symbol}
    # allowsnulls::Vector{Bool}
    hasnulls::Vector{Bool}

    function Table(index, columns)
        ncols = length(columns)
        # allowsnulls = Vector{Bool}(ncols)
        hasnulls = Vector{Bool}(ncols)
        if ncols > 1
            nrows = length(columns[1])
            equallengths = true
            for (j, col) in enumerate(columns)
                equallengths &= length(col) == nrows
                # allowsnulls[j] = _allowsnulls(col)
                hasnulls[j] = _hasnulls(col)
            end
            if !equallengths
                msg = "All columns in a Table must be the same length"
                throw(ArgumentError(msg))
            end
        end
        fields = Array{Symbol}(ncols)
        for key in keys(index)
            key = Symbol(replace_dots(string(key)))
            fields[index[key]] = key
        end
        length(index) == length(columns) || error()
        new(index, columns, fields, hasnulls)
    end
end

replace_dots(field) = searchindex(field, ".") > 0 ? replace(field, ".", "_") : field

"""
Initialize an empty `Table`.
"""
empty(tbl::Table) = Table()

# _allowsnulls(A::Array) = false
# _allowsnulls(A::AbstractArray) = true
_hasnulls(A::Array) = false
_hasnulls(A::AbstractArray) = anynull(A)

"""
    Table([kwargs...])

`Table`s can be initialized with field-column pairs by passing the latter as
keyword arguments.

Examples:

* `Table(a = [1, 2], b = [3, 4])`
* `Table(ID = collect(1:10))`

Notes: Columns are not coerced upon `Table` initialization.
"""
function (::Type{Table})(; kwargs...)
    res = Table(Dict{Symbol,Int}(), [])
    for (k, v) in kwargs
        res[k] = v
    end
    return res
end

## Traits

AbstractTables.tblrowdim(::Table) = AbstractTables.HasRowDim()

## Primitives

"""
    `index(tbl::Table)`

Obtain the index of `tbl`.
"""
index(tbl::Table) = tbl.index

"""
    `columns(tbl::Table)`

Obtain the columns of `tbl`.
"""
columns(tbl::Table) = tbl.columns

"""
    `fields(tbl::Table)`

Obtain an ordered list of fields (column names) of `tbl`.

Notes: `fields(tbl)` is dual to `index(tbl)` in the sense that

fields(tbl)[(index(tbl)[fld]] == fld
index(tbl)[(fields(tbl)[i]] == i
"""
fields(tbl::Table) = tbl.fields

"""
    `nrow(tbl::Table)`

Obtain the number of rows contained in `tbl`.
"""
AbstractTables.nrow(tbl::Table) = ncol(tbl) > 0 ? length(columns(tbl)[1]) : 0

"""
    `getindex(tbl::Table, fld::Symbol)`

Extract the column with field `fld` from `tbl`. Equivalent to `tbl[fld]`
"""
Base.getindex(tbl::Table, fld::Symbol) = columns(tbl)[index(tbl)[fld]]

"""
    `setindex(tbl::Table, col, fld::Symbol)`

Set `col` as the column respective to `fld` in `tbl`. Equivalent to
`tbl[fld] = col`

Notes: `col` will not be coerced. `length(col)` must equal `nrow(tbl)`.
"""
function Base.setindex!(tbl::Table, col::AbstractArray, field::Symbol)
    field = Symbol(replace_dots(string(field)))
    nrows, ncols = nrow(tbl), ncol(tbl)
    if (ncols > 0) & (length(col) != nrows)
        msg = "All columns in a Table must be the same length"
        throw(ArgumentError(msg))
    end
    j = get!(()->ncols+1, index(tbl), field)
    cols = columns(tbl)
    flds = fields(tbl)
    if j <= ncols
        cols[j] = convert(NullableArray, col)
        # tbl.allowsnulls[j] = _allowsnulls(col)
        tbl.hasnulls[j] = _hasnulls(col)
    else
        push!(cols, convert(NullableArray, col))
        push!(flds, field)
        # push!(tbl.allowsnulls, _allowsnulls(col))
        push!(tbl.hasnulls, _hasnulls(col))
    end
    return col
end

"""
    `copy(tbl)`

Return a copy of `tbl`.

Notes: applies `copy` to each column and inserts the copies into an `empty`
`Table`.
"""
function Base.copy(tbl::Table)
    new_tbl = Table()
    for (fld, col) in eachcol(tbl)
        new_tbl[fld] = copy(col)
    end
    return new_tbl
end

##### Row iteration #####

"""
"""
immutable TableRowIterator{T}
    cols::T
end

Base.start(itr::TableRowIterator) = 1
@generated function Base.next{T}(itr::TableRowIterator{T}, st)
    ncols = length(fieldnames(T))
    ex_tup = Expr(:tuple)
    for j in 1:ncols
        push!(ex_tup.args, :( itr.cols[$j][st] ))
    end
    return quote
        return ($ex_tup, st+1)
    end
end
function Base.done(itr::TableRowIterator, st)
    lim = length(itr.cols) > 0 ? length(itr.cols[1]) : 0
    st > lim
end

AbstractTables.eachrow(tbl::Table) = TableRowIterator(tuple(columns(tbl)...))
function AbstractTables.eachrow(tbl::Table, flds...)
    cols = [ tbl[fld] for fld in flds ]
    TableRowIterator(tuple(cols...))
end

# Other

function Base.isequal(tbl1::Table, tbl2::Table)
    isequal(ncol(tbl1), ncol(tbl2)) || return false
    # isequal(tbl1.allowsnulls, tbl2.allowsnulls) || return false
    isequal(tbl1.hasnulls, tbl2.hasnulls) || return false
    for ((fld1, col1), (fld2, col2)) in zip(eachcol(tbl1), eachcol(tbl2))
        isequal(fld1, fld2) || return false
        isequal(col1, col2) || return false
    end
    return true
end

function Base.hash(tbl::Table)
    # h = hash(tbl.allowsnulls) + 1
    h = hash(tbl.hasnulls) + 1
    for (i, (fld, col)) in enumerate(eachcol(tbl))
        h = hash(i, h)
        h = hash(fld, h)
        h = hash(tbl[fld], h)
    end
    return @compat UInt(h)
end
