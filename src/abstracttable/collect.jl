function _collect(tbl::AbstractTable, g::SelectNode)
    new_tbl = empty(tbl)
    for (res_fld, f, arg_flds) in parts(helper(g))
        new_tbl[res_fld] = rhs_select(f, tbl, arg_flds)
    end
    return new_tbl
end

function _collect(tbl::AbstractTable, g::FilterNode)
    f, arg_flds = parts(helper(g))[1]
    new_tbl = rhs_filter(f, tbl, arg_flds)
    return new_tbl
end

function _collect(tbl::AbstractTable, g::SummarizeNode)
    new_tbl = empty(tbl)
    for (res_fld, f, g, ind2sym) in parts(helper(g))
        new_tbl[res_fld] = rhs_summarize(f, g, tbl, ind2sym)
    end
    return new_tbl
end

function _collect(tbl::AbstractTable, g::GroupbyNode)
    group_indices = _indices(tbl, g)
    return GroupedTable(tbl, group_indices, g.args)
end
