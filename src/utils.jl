"""
TODO: Check if this function (which potentially has to do run-time method
dispatch) is a bottleneck. If there were no uncertainty whether elements were
going to be Nullable, that could be resolved.
NOTE: Quick testing suggests this is not the bottleneck for most code.
"""
@inline function hasnulls(itr::Any)::Bool
    res = false
    for el in itr
        if isa(el, Nullable)
            res |= isnull(el)
        end
    end
    return res
end

"""
Like get(x::Nullable), but applicable to all types. Also unsafe, so
conditional on some checks happening before this point.
"""
@inline unwrap(x::Nullable) = x.value
@inline unwrap(x::Any) = x
