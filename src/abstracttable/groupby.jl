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
        kernel_expr, arg_fields = build_kernel_ex(e)
        push!(
            helper_parts_exs,
            :( ($kernel_expr, $arg_fields) )
        )
    end
    return helper_parts_exs
end

"""
"""
@noinline function _indices(tbl, g::GroupbyNode)
    # Extract the columns from the table and create a tuple iterator.
    helpers = helper_parts(g)
    N = length(helpers)
    f_itr_pairs = Any[]
    for (f, arg_fields) in helpers
        cols = [tbl[field] for field in arg_fields]
        row_itr = zip(cols...)
        push!(f_itr_pairs, (f, row_itr))
    end

    # TODO: Type this more strongly when possible.
    group_indices = Dict{Any, Vector{Int}}()

    # Fill the new column in row-by-row.
    _grow_indices!(Val{N}(), group_indices, f_itr_pairs...)

    # Return the output
    return group_indices
end

@noinline @generated function _grow_indices!{N}(::Val{N}, indices, f_itr_pairs...)
    row_subset_tuple_ex = Expr(:tuple)
    group_tuple_ex = Expr(:tuple)
    for i in 1:N
        push!(row_subset_tuple_ex.args, Symbol("row_subset_$i"))
        push!(group_tuple_ex.args, Symbol("group_$i"))
    end

    return quote
        @nexprs $N j->begin
            f_j = f_itr_pairs[j][1]
            itr_j = f_itr_pairs[j][2]
        end
        zipped_row_itrs = @ncall $N zip itr

        for (i, $row_subset_tuple_ex) in enumerate(zipped_row_itrs)
            @nexprs $N j -> begin
                if hasnulls(row_subset_j)
                    group_j = Nullable{Union{}}()
                else
                    group_j = f_j(map(unwrap, row_subset_j))
                end
            end

            if haskey(indices, $group_tuple_ex)
                push!(indices[$group_tuple_ex], i)
            else
                indices[$group_tuple_ex] = Int[i]
            end
        end
        return
    end
end
