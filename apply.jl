# Given a table as a dictionary of NullableArray objects, an ordered list of column
# names and a tuple-to-scalar function, create a tuple iterator by zipping by the
# columns in the indicated order, then allocate a NullableArray into which to store
# the results.
@noinline function _apply_tuple_func(f, tbl, colnames)
    cols = [tbl[colname] for colname in colnames]
    tpl_itr = zip(cols...)
    # TODO: Handle the possibility of columns that are not NullableArrays here.
    inner_types = map(x -> eltype(eltype(x)), cols)
    t = Core.Inference.return_type(f, (Tuple{inner_types...}, ))
    # TODO: Branch here on non-concrete types.
    if !isleaftype(t)
        error("Unable to process type-inference-unfriendly functions")
    end
    n = length(tbl[colnames[1]])
    output = NullableArray(t, n)
    _fill_output!(output, f, tpl_itr)
    return output
end
