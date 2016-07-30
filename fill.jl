# TODO: Check if this function (which potentially has to do run-time)
# is a bottleneck. If there were no uncertainty whether elements were
# going to be Nullable, that could be resolved.
@inline function _hasnulls(itr::Any)
    res = false
    for el in itr
        if isa(el, Nullable)
            res |= isnull(el)
        end
    end
    return res
end

# Like get(x::Nullable), but applicable to all types.
@inline _unwrap(x::Nullable) = x.value
@inline _unwrap(x::Any) = x

# Fill a NullableArray with the results of evaluating a tuple-to-scalar
# function over a sequence of tuples generator by an iterator object.
# In order to automatically implement lifting, we check  whether any element of
# the tuple is nullable and (conditional on being nullable) null-valued.

@noinline function _fill_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if _hasnulls(tpl)
            output.isnull[i] = true
        else
            output.isnull[i] = false
            output.values[i] = f(map(_unwrap, tpl))
        end
    end
    return
end
