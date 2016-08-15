using Base.Cartesian: @nexprs

### Helper

function build_helper_ex(g::GroupbyNode)
    # TODO: check_node(g)
    helper_parts_ex = Expr(:ref, Tuple, build_helper_parts(g)...)
    return :( Helper{GroupbyNode}($helper_parts_ex) )
end

function build_helper_parts(g::GroupbyNode)
    helper_parts_exs = Vector{Expr}()
    for e in g.args
        is_predicate = isa(e, Expr) ? true : false
        kernel_expr, arg_fields = build_kernel_ex(e)
        push!(
            helper_parts_exs,
            :( ($is_predicate, $kernel_expr, $arg_fields) )
        )
    end
    return helper_parts_exs
end

function build_group_levels(group_indices, ngroupbys)
    joint_group_levels = collect(keys(group_indices))
    group_levels = Vector{Vector}(ngroupbys)
    for j in 1:ngroupbys
        group_levels[j] = [ level[j] for level in joint_group_levels ]
    end
    map!(unique, group_levels)
    return group_levels
end

@noinline function build_group_indices(tbl, groupbys)
    cols = [ tbl[groupby] for groupby in groupbys ]
    row_itr = zip(cols...)

    group_indices = Dict{Any, Vector{Int}}()

    _grow_indices!(group_indices, row_itr)

    return group_indices
end

function _grow_indices!(group_indices, row_itr)
    for (i, row) in enumerate(row_itr)
        group_level = row

        if haskey(group_indices, group_level)
            push!(group_indices[group_level], i)
        else
            group_indices[group_level] = [i]
        end
    end
    return group_indices
end
