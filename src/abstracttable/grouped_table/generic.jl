function _preprocess(f, arg_fields, g_tbl, key)
    # Extract columns
    source = g_tbl.source
    indices = g_tbl.group_indices[key]
    row_itr = zip([ source[field][indices] for field in arg_fields ]...)

    # Determine the type of the iterator (possibly after unwrapping Nullable
    # types)
    inner_eltypes = map(eltype, eltypes(source, arg_fields...))

    # See if inference knows the return type for rowwise kernel
    T = Core.Inference.return_type(f, (Tuple{inner_eltypes...}, ))

    # Branch here on non-concrete types on a semantically correct path.
    if !isleaftype(T)
        # TODO: Make this a real code path based on the type-inference
        # independent map implementation in Base.
        @printf("WARNING: Failed to type-infer expression: found %s", t)
        T = Any
    end
    return T, row_itr
end
