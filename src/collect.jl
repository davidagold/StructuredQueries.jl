function Base.collect(g::QueryNode)
    has_src(g) || error()
    return _collect(g)
end

_collect(d::DataNode) = d.input
_collect(g::QueryNode) = _collect(_collect(g.input), g)
_collect(::CurryNode, g::QueryNode) = x -> _collect(x, g)

### AbstractTable implementations

function _collect(tbl::AbstractTable, g::FilterNode)
    helper = g.helper
    indices = _boolean_tuple_func(helper.kernel, tbl, helper.flds)
    _get_subset(tbl, indices)
end

function _collect(tbl::AbstractTable, g::MutateNode)
    helper = g.helper
    for (res_fld, lambda, arg_flds) in helper.helpers
        tbl[res_fld] = _apply_mutate(lambda, tbl, arg_flds)
    end
    tbl
end

function _collect(tbl::AbstractTable, g::SummarizeNode)
    res = empty(tbl)
    helper = g.helper
    for (col_name, kernel, g, ind2sym) in helper.parts
        res[col_name] = _summarize_tuple_func(kernel, g, tbl, ind2sym)
    end
    return res
end
