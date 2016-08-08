### Helper

function build_helper_ex(g::FilterNode)
    kernel_ex, flds = build_helper_parts(g)
    return :( Helper{FilterNode}([($kernel_ex, $flds)]) )
end

function build_helper_parts(g::FilterNode)
    filter_pred = aggregate(g.args)
    kernel_ex, arg_flds = build_kernel_ex(filter_pred)
end

aggregate(args) = foldl((x,y)->:($x & $y), args)

### RHS

@noinline function rhs_filter(f, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Pre-allocate the table's new column.
    n = length(tbl[colnames[1]])
    indices = Array(Int, 0)

    # Fill the new column in row-by-row.
    find_indices!(indices, f, tpl_itr)

    # Return subset of tbl matching indices
    return get_subset_of_rows(tbl, indices)
end

"""
Find all of row indices satisfying a predicate function, `f`.
"""
@noinline function find_indices!(indices, f, tuple_iterator)
    for (i, tpl) in enumerate(tuple_iterator)
        # We only include results for which the predicate is true.
        # This means we exclude both NULL and false values.
        if !hasnulls(tpl) && f(map(unwrap, tpl))::Bool
            push!(indices, i)
        end
    end
    return
end

function partial_copy!(
    new_col::NullableVector,
    col::NullableVector,
    indices::Vector{Int},
)::Void
    for (new_ind, old_ind) in enumerate(indices)
        if col.isnull[old_ind]
            new_col.isnull[new_ind] = true
        else
            new_col.isnull[new_ind] = false
            new_col.values[new_ind] = col.values[old_ind]
        end
    end
    return
end

function get_subset_of_rows(tbl, indices)::Table
    n = length(indices)
    new_tbl = empty(tbl)
    for (fld, col) in eachcol(tbl)
        new_col = NullableArray(eltype(eltype(col)), n)
        partial_copy!(new_col, col, indices)
        new_tbl[fld] = new_col
    end
    return new_tbl
end
