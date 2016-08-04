function Base.collect(g::QueryNode)
    has_src(g) || error()
    return _collect(g)
end

_collect(d::DataNode) = d.input
_collect(g::QueryNode) = _collect(_collect(g.input), g)
_collect(::CurryNode, g::QueryNode) = x -> _collect(x, g)

### AbstractTable implementations

function _collect(tbl::AbstractTable, g::SelectNode)
    new_tbl = empty(tbl)
    for fld in g.args
        new_tbl[fld] = copy(tbl[fld])
    end
    return new_tbl
end

function _collect(tbl::AbstractTable, g::FilterNode)
    helper = g.helper
    kernel, argfields = helper.parts[1]
    indices = _filter_apply(kernel, tbl, argfields)
    return _get_subset(tbl, indices)
end

function _collect(tbl::AbstractTable, g::MutateNode)
    new_tbl = copy(tbl)
    helper = g.helper
    for (res_fld, kernel, arg_flds) in helper.parts
        new_tbl[res_fld] = _mutate_apply(kernel, tbl, arg_flds)
    end
    return new_tbl
end

function _collect(tbl::AbstractTable, g::SummarizeNode)
    new_tbl = empty(tbl)
    helper = g.helper
    for (col_name, kernel, g, ind2sym) in helper.parts
        new_tbl[col_name] = NullableArray([_summarize_apply(kernel, g, tbl, ind2sym)])
    end
    return new_tbl
end
