function _collect(tbl::AbstractTable, g::SelectNode)
    new_tbl = empty(tbl)
    for (res_fld, f, arg_flds) in parts(helper(g))
        if isa(f, SelectStar)
            select_star!(new_tbl, eachcol(tbl))
        else
            new_tbl[res_fld] = rhs_select(f, tbl, arg_flds)
        end
    end
    return new_tbl
end

function select_star!(new_tbl, col_itr)
    for (field, col) in col_itr
        new_tbl[field] = col
    end
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
    new_tbl = copy(tbl)
    groupby_metadata = Dict{Expr, Symbol}()
    i = 1
    for ((is_predicate, f, arg_fields), arg) in zip(helper_parts(g), g.args)
        if is_predicate
            group_pred_field = Symbol("group_pred_$i")
            groupby_metadata[arg] = group_pred_field
            new_tbl[group_pred_field] = rhs_select(f, tbl, arg_fields)
            i += 1
        end
    end
    groupbys = map(x->isa(x, Symbol) ? x : groupby_metadata[x], g.args)
    group_indices = build_group_indices(new_tbl, groupbys)
    group_levels = build_group_levels(group_indices, length(groupbys))
    return GroupedTable(
        new_tbl,
        group_indices,
        AbstractTables.GroupLevels(group_levels),
        g.args,
        groupby_metadata
    )
end
