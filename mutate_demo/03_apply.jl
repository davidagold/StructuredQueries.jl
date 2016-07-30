"""
Given a table as a dictionary of NullableArray objects, an ordered list of
column names, and a tuple-to-scalar function, create a tuple iterator by
zipping by the columns in the indicated order, then allocate a NullableArray
into which to store the results.
"""
@noinline function _apply_tuple_func(f, tbl, colnames)
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

    # Branch here on non-concrete types.
    if !isleaftype(t)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        error("Unable to process type-inference-unfriendly functions")
    end

    # Pre-allocate the table's new column.
    n = length(tbl[colnames[1]])
    output = NullableArray(t, n)

    # Fill the new column in row-by-row.
    _fill_output!(output, f, tpl_itr)

    # Return the output
    return output
end
