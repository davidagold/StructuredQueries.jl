"""
Arguments:

    * `f`: a row kernel
    * `tbl`: An `AbstractTable`
    * `arg_flds`: A mapping from numeric indices to names of argument columns

Returns:

    * `T::DataType`: the inferred type of applying `f` to an argument
    with signature the inner `eltype`s of the argument columns
    * `row_itr`: An iterator over the rows of the argument columns

"""
@noinline function _preprocess(f, tbl, arg_flds)
    # Extract columns
    row_itr = eachrow(tbl, arg_flds...)

    # Determine the type of the iterator (possibly after unwrapping Nullable
    # types)
    inner_eltypes = map(eltype, eltypes(tbl, arg_flds...))

    # See if inference knows the return type for rowwise kernel
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...}, ))

    # Branch here on non-concrete types on a semantically correct path.
    if !isleaftype(T)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s", T)
        T = Any
    end
    return T, row_itr
end

function build_kernel_ex(e::Any)
    tuple_name = gensym()
    s = find_symbols(e)
    mapping, reverse_mapping = map_symbols(s)
    new_e = replace_symbols(e, mapping, tuple_name)
    return (
        Expr(:->, tuple_name, Expr(:block, new_e)),
        reverse_mapping,
    )
end
