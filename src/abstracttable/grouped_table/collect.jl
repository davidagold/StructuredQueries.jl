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
    f, arg_fields = parts(helper(g))[1]
    new_source_tbl = rhs_filter(f, g_tbl.source, arg_fields)
    return _grouped_table(new_source_tbl, g_tbl.groupbys, g_tbl.metadata)
end
