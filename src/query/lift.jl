# TODO: Check if this function (which potentially has to do run-time method
# dispatch) is a bottleneck. If there were no uncertainty whether elements were
# going to be Nullable, that could be resolved.
# NOTE: Quick testing suggests this is not the bottleneck for most code.
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
@inline unsafe_get(x::Nullable) = x.value
@inline unsafe_get(x::Any) = x

function lift(f, T, x)
    if x.isnull
        return Nullable{T}()
    else
        return Nullable(f(unwrap(x)))
    end
end

function lift(f, T, x1, x2)
    if x.isnull | y.isnull
        return Nullable{T}()
    else
        return Nullable(f(unwrap(x1), unwrap(x2)))
    end
end

function lift(f, T, xs...)
    if hasnulls(xs)
        return Nullable{T}()
    else
        return Nullable(f(map(unwrap, xs)...))
    end
end

# 3VL

function lift(f::typeof(&), ::Type{Bool}, x, y)
    return ifelse(
        isnull(x),
        ifelse(
            isnull(y),
            Nullable{Bool}(),
            ifelse(
                unwrap(y),
                Nullable{Bool}(),
                false
            )
        ),
        ifelse(
            isnull(y),
            ifelse(
                unrap(x),
                Nullable{Bool}(),
                false
            ),
            x & y
        )
    )
end

function lift(f::typeof(|), ::Type{Bool}, x, y)
    return ifelse(
        isnull(x),
        ifelse(
            isnull(y),
            Nullable{Bool}(),
            ifelse(
                unwrap(y),
                true,
                Nullable{Bool}()
            )
        ),
        ifelse(
            isnull(y),
            ifelse(
                unwrap(x),
                true,
                Nullable{Bool}()
            ),
            x | y
        )
    )
end
