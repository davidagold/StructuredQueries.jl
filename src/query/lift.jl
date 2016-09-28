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

function lift(f::typeof(&), ::Type{Bool}, x, y)::Nullable{Bool}
    return ifelse(
        isnull(x),
        ifelse(
            isnull(y),
            Nullable{Bool}(),
            ifelse(
                unwrap(y),
                Nullable{Bool}(),
                Nullable(false)
            )
        ),
        ifelse(
            isnull(y),
            ifelse(
                unwrap(x),
                Nullable{Bool}(),
                Nullable(false)
            ),
            Nullable(x.value & y.value)
        )
    )
end

function lift(f::typeof(|), ::Type{Bool}, x, y)::Nullable{Bool}
    return ifelse(
        isnull(x),
        ifelse(
            isnull(y),
            Nullable{Bool}(),
            ifelse(
                unwrap(y),
                Nullable(true),
                Nullable{Bool}()
            )
        ),
        ifelse(
            isnull(y),
            ifelse(
                unwrap(x),
                Nullable(true),
                Nullable{Bool}()
            ),
            Nullable(x.value | y.value)
        )
    )
end
