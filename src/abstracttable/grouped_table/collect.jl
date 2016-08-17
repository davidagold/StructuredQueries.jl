function _collect(g_tbl::GroupedTable, g::SelectNode)
    source_tbl = g_tbl.source
    new_source_tbl = empty(g_tbl.source)
    groupby_fields = map(x->isa(x, Symbol) ? x : g_tbl.metadata[x], g_tbl.groupbys)
    for groupby_field in groupby_fields
        new_source_tbl[groupby_field] = source_tbl[groupby_field]
    end
    for (res_fld, f, arg_flds) in parts(helper(g))
        new_source_tbl[res_fld] = rhs_select(f, source_tbl, arg_flds)
    end
    return GroupedTable(
        new_source_tbl,
        g_tbl.group_indices,
        g_tbl.group_levels,
        g_tbl.groupbys,
        g_tbl.metadata
    )
end

function _collect(g_tbl::GroupedTable, g::SummarizeNode)
    ngroupbys = length(g_tbl.groupbys)
    return group_summarize(Val{ngroupbys}(), g_tbl, g)
end

function _collect(g_tbl::GroupedTable, g::FilterNode)
    f, arg_flds = parts(helper(g))[1]
    
    group_indices = g_tbl.group_indices
    for group in collect(keys(group_indices))
        indices = group_indices[group]

    end
end
