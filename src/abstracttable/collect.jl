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
    source_tbl = copy(tbl)
    groupby_metadata = Dict{Expr, Symbol}()
    _pre_group!(source_tbl, g, groupby_metadata)
    return _grouped_table(source_tbl, g.args, groupby_metadata)
end

function _pre_group!(tbl, g, groupby_metadata)
    i = 1
    for ((is_predicate, f, arg_fields), arg) in zip(helper_parts(g), g.args)
        if is_predicate
            group_pred_field = Symbol("group_pred_$i")
            groupby_metadata[arg] = group_pred_field
            tbl[group_pred_field] = rhs_select(f, tbl, arg_fields)
            i += 1
        end
    end
end


function _grouped_table(tbl, groupbys, groupby_metadata)
    groupby_fields = map(x->isa(x, Symbol) ? x : groupby_metadata[x], groupbys)
    group_indices = build_group_indices(tbl, groupby_fields)
    group_levels = build_group_levels(group_indices, length(groupby_fields))
    return GroupedTable(
        tbl,
        group_indices,
        AbstractTables.GroupLevels(group_levels),
        groupbys,
        groupby_metadata
    )
end
