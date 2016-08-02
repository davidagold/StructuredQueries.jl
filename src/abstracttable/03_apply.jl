#=
The following functions, along with those in `02_fill.jl`, are the primary
engine for executing manipulation graphs over AbstractTable types. The
strategy for execution generally involves three layers:
    1) _collect
    2) an "apply" method (from below)
    3) a "fill"/"grow" method (from `02_fill.jl`)
=#

"""
Arguments:

    * `kernel`: a row kernel
    * `tbl`: An `AbstractTable`
    * `argfields`: A mapping from numeric indices to names of argument columns

Returns:

    * `T::DataType`: the inferred type of applying `kernel` to an argument
    with signature the inner `eltype`s of the argument columns
    * `row_itr`: An iterator over the rows of the argument columns

"""
@noinline function _preprocess(kernel, tbl, argfields)
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
    return T, row_itr
end

"""
"""
function _mutate_apply(kernel, tbl, argfields)
    # Pre-process table in terms of kernel and argument column names
    T, row_itr = _preprocess(kernel, tbl, argfields)

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
@noinline function _filter_apply(f, tbl, colnames)
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
@noinline function _summarize_apply(f, g, tbl, argfields)
    # Pre-process table w/r/t row kernel and argument column names
    T, row_itr = _preprocess(f, tbl, argfields)

    # Allocate a temporary column.
    temporary = Array(T, 0)

    # Fill the new column in row-by-row, skipping nulls.
    _grow_nonnull_output!(temporary, f, row_itr)

    # Return the summarization function applied to the temporary.
    return g(temporary)
end
