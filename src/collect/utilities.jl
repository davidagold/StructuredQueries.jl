"""
    hasnulls(itr)

Return `true` if any element in `itr` is null; otherwise return `false`.
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
