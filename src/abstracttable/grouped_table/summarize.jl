new_groupby_field!(groupby::Symbol, i, metadata) = groupby
function new_groupby_field!(groupby::Expr, i, metadata)
    groupby_field = Symbol("group_pred_$i")
    metadata[groupby_field] = groupby
    return groupby_field
end

# new_groupby_column(groupby, g_tbl) = Vector{Bool}()
# function new_groupby_column(groupby, g_tbl)
#     source = g_tbl.source
#     # T = eltypes(source, groupby)[1]
#     # return Vector{T}()
#     return similar(source[groupby], 0)
# end

new_groupby_column(groupby_field, tbl) = similar(tbl[groupby_field], 0)

function build_groupby_resources(g_tbl::GroupedTable)
    groupby_columns = Dict{Symbol, Vector}()
    groupby_fields = map(x->isa(x, Symbol) ? x : g_tbl.metadata[x], g_tbl.groupbys)
    for groupby_field in groupby_fields
        groupby_column = new_groupby_column(groupby_field, g_tbl.source)
        groupby_columns[groupby_field] = groupby_column
    end
    return groupby_fields, groupby_columns
end

@generated function group_summarize{N}(::Val{N}, g_tbl, node)
    # generate expression for (group_1, ..., group_n) inner loop variables
    group_tuple_ex = Expr(:tuple)
    for i in 1:N
        push!(group_tuple_ex.args, Symbol("group_$i"))
    end

    return quote
        groupby_fields, groupby_columns  = build_groupby_resources(g_tbl)
        res_columns = Dict{Symbol, Vector}()
        group_levels = g_tbl.group_levels

        @nloops $N group group_levels begin
            if !haskey(g_tbl.group_indices, $group_tuple_ex)
                continue
            end

            # push group levels to appropriate groupby columns
            @nexprs $N j-> push!(groupby_columns[groupby_fields[j]], group_j)

            # compute each summarization and insert into appropriate
            # result column
            for (res_field, f, g, arg_fields) in helper_parts(node)
                if haskey(res_columns, res_field)
                    push!(
                        res_columns[res_field],
                        rhs_summarize(f, g, arg_fields, g_tbl, $group_tuple_ex)
                    )
                else
                    res_columns[res_field] =
                        [rhs_summarize(f, g, arg_fields, g_tbl, $group_tuple_ex)]
                end
            end
        end

        new_tbl = Table()
        new_tbl.metadata[:groupby_predicates] = g_tbl.metadata
        for groupby_field in groupby_fields
            new_tbl[groupby_field] = groupby_columns[groupby_field]
        end
        for (res_field, f, g, arg_fields) in parts(helper(node))
            new_tbl[res_field] = res_columns[res_field]
        end
        return new_tbl
    end
end

function rhs_summarize(f, g, arg_fields, g_tbl, key)
    T, row_itr = _preprocess(f, arg_fields, g_tbl, key)

    # Allocate a temporary column.
    temporary = Array(T, 0)

    # Fill the new column in row-by-row, skipping nulls.
    grow_nonnull_output!(temporary, f, row_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
