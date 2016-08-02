@noinline function _apply_mutate(kernel, tbl, argfields)
    # Extract columns
    row_itr = eachrow(tbl, argfields...)
    # Determine the type of the iterator (possibly after unwrapping Nullable
    # types)
    inner_eltypes = map(eltype, eltypes(tbl, argfields...))
    # See if inference knows the return type for rowwise kernel
    T = Core.Inference.return_type(kernel, (Tuple{inner_eltypes...}, ))
    # Branch here on non-concrete types on a semantically correct path.
    if !isleaftype(T)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s", t)
        T = Any
    end
    # Pre-allocate the table's new column.
    n = length(tbl[argfields[1]])
    output = NullableArray(T, n)
    # Fill the new column in row-by-row.
    # @code_warntype _fill_output!(output, f, row_itr)
    _fill_output!(output, kernel, row_itr)
    # Return the output
    return output
end

"""
Boolean tuple func checker
"""
@noinline function _boolean_tuple_func(f, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Pre-allocate the table's new column.
    n = length(tbl[colnames[1]])
    indices = Array(Int, 0)

    # Fill the new column in row-by-row.
    _grow_output!(indices, f, tpl_itr)

    # Return the output
    return indices
end

"""
Summarize tuple function
"""
@noinline function _summarize_tuple_func(f, g, tbl, colnames)
    # Extract the columns from the table and create a tuple iterator.
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)

    # Determine the tuple type of the iterator after unwrapping all Nullables.
    #
    # TODO: Handle the possibility of columns that are not NullableArrays here.
    # Better yet, don't handle that possibility and avoid a lot of shanigans
    # elsewhere.
    inner_types = map(x -> eltype(eltype(x)), cols)

    # See if inference knows the return type for the tuple-to-scalar function.
    t = Core.Inference.return_type(f, (Tuple{inner_types...}, ))

    # If there is no method found (or it returns nothing), t === Union{}.
    # if t == Union{}
    #     error("No method found for those types")
    # end

    # Branch here on non-concrete types.
    if !isleaftype(t)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s", t)
        t = Any
    end

    # Allocate a temporary column.
    temporary = Array(t, 0)

    # Fill the new column in row-by-row, skipping nulls.
    _grow_nonnull_output!(temporary, f, tpl_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
