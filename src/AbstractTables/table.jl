"""
A tabular data type.

Fields:

* index::Dict{Symbol, Int}
* columns::Vector{Any}

Notes:
"""
type Table <: AbstractTable
    index::Dict{Symbol, Int}
    columns::Vector{Any}
    allowsnulls::Vector{Bool}
    hasnulls::Vector{Bool}

    function Table(index, columns)
        ncols = length(columns)
        allowsnulls = Vector{Bool}(ncols)
        hasnulls = Vector{Bool}(ncols)
        if ncols > 1
            nrows = length(columns[1])
            equallengths = true
            for (j, col) in enumerate(columns)
                equallengths &= length(col) == nrows
                allowsnulls[j] = _allowsnulls(col)
                hasnulls[j] = _hasnulls(col)
            end
            if !equallengths
                msg = "All columns in a Table must be the same length"
                throw(ArgumentError(msg))
            end
        end
        length(index) == length(columns) || error()
        new(index, columns, allowsnulls, hasnulls)
    end
end

_allowsnulls(A::Array) = false
_allowsnulls(A::AbstractArray) = true
_hasnulls(A::Array) = false
_hasnulls(A::AbstractArray) = anynull(A)

"""
"""
function Table(; kwargs...)
    res = Table(Dict{Symbol,Int}(), [])
    for (k, v) in kwargs
        res[k] = v
    end
    return res
end

"""
"""
index(tbl::Table) = tbl.index

"""
"""
columns(tbl::Table) = tbl.columns

"""
`fields(tbl)` is dual to `index(tbl)` in the sense that

fields(tbl)[(index(tbl)[fld]] == fld
index(tbl)[(fields(tbl)[i]] == i
"""
function fields(tbl::Table)
    res = Array{Symbol}(ncol(tbl))
    idx = index(tbl)
    for key in keys(idx)
        res[idx[key]] = key
    end
    res
end
nrow(tbl::Table) = ncol(tbl) > 0 ? length(columns(tbl)[1]) : 0

"""
"""
Base.getindex(tbl::Table, fld::Symbol) = columns(tbl)[index(tbl)[fld]]

"""
"""
function Base.setindex!(tbl::Table, col, fld::Symbol)
    nrows, ncols = nrow(tbl), ncol(tbl)
    if (ncols > 0) & (length(col) != nrows)
        msg = "All columns in a Table must be the same length"
        throw(ArgumentError(msg))
    end
    j = get!(()->ncols+1, index(tbl), fld)
    cols = columns(tbl)
    if j <= ncols
        cols[j] = col
        tbl.allowsnulls[j] = _allowsnulls(col)
        tbl.hasnulls[j] = _hasnulls(col)
    else
        push!(cols, col)
        push!(tbl.allowsnulls, _allowsnulls(col))
        push!(tbl.hasnulls, _hasnulls(col))
    end
    return col
end

##### Row iteration #####

"""
"""
immutable TableRowIterator{N}
    cols::Vector{Any}
end

Base.start(itr::TableRowIterator) = 1
@generated function Base.next{N}(itr::TableRowIterator{N}, st)
    ex_tup = Expr(:tuple)
    for j in 1:N
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

"""
"""
eachrow(tbl::Table) = TableRowIterator{ncol(tbl)}(columns(tbl))
function eachrow(tbl::Table, flds...)
    cols = [ tbl[fld] for fld in flds ]
    TableRowIterator{length(cols)}(cols)
end
