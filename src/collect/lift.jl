# TODO: Move this to Compat.jl
if VERSION < v"0.6.0-dev.848"
    unsafe_get(x::Nullable) = x.value
    unsafe_get(x) = x
    Base.isnull(x) = false
end

# handle julia#18510
if VERSION < v"0.6.0-dev.826"
    _field2(x) = x
else
    _field2(x) = !x
end

# Base.null_safe_op is not defined on v0.5
if VERSION < v"0.6.0-dev.0"
    # TODO: Find parsimonious way to support null_safe_op optimizations on 0.5
    null_safe_op(f, xs...) = false
else
    using Base: null_safe_op
end

##############################################################################
##
## Standard lifting semantics
##
## For a function call f(xs...), return null if any x in xs is null;
## otherwise, return f applied to values of xs.
##
##############################################################################

@inline function lift(f, x)
    if null_safe_op(f, typeof(x))
        return Nullable(f(x.value), _field2(isnull(x)))
    else
        U = Core.Inference.return_type(f, Tuple{eltype(typeof(x))})
        if isnull(x)
            return Nullable{U}()
        else
            return Nullable(f(unsafe_get(x)))
        end
    end
end

@inline function lift(f, x1, x2)
    if null_safe_op(f, typeof(x1), typeof(x2))
        return Nullable(
            f(x1.value, x2.value),
            _field2(isnull(x1) | isnull(x2))
        )
    else
        U = Core.Inference.return_type(
            f, Tuple{eltype(typeof(x1)), eltype(typeof(x2))}
        )
        if isnull(x1) | isnull(x2)
            return Nullable{U}()
        else
            return Nullable(f(unsafe_get(x1), unsafe_get(x2)))
        end
    end
end

@inline function lift(f, xs...)
    if null_safe_op(f, map(typeof, xs)...)
        return Nullable(
            f(map(unsafe_get, xs)...),
            _field2(mapreduce(isnull, |, xs))
        )
    else
        U = Core.Inference.return_type(
            f, Tuple{map(x->eltype(typeof(x)), xs)...}
        )
        if hasnulls(xs)
            return Nullable{U}()
        else
            return Nullable(f(map(unsafe_get, xs)...))
        end
    end
end

##############################################################################
##
## Non-standard lifting semantics
##
##############################################################################

# three-valued logic implementation
@inline function lift(::typeof(&), x, y)::Nullable{Bool}
    return ifelse( isnull(x),
        ifelse( isnull(y),
            Nullable{Bool}(),                       # x, y null
            ifelse( unsafe_get(y),
                Nullable{Bool}(),                   # x null, y == true
                Nullable(false)                     # x null, y == false
            )
        ),
        ifelse( isnull(y),
            ifelse( unsafe_get(x),
                Nullable{Bool}(),                   # x == true, y null
                Nullable(false)                     # x == false, y null
            ),
            Nullable(unsafe_get(x) & unsafe_get(y)) # x, y not null
        )
    )
end

# three-valued logic implementation
@inline function lift(::typeof(|), x, y)::Nullable{Bool}
    return ifelse( isnull(x),
        ifelse( isnull(y),
            Nullable{Bool}(),                       # x, y null
            ifelse( unsafe_get(y),
                Nullable(true),                     # x null, y == true
                Nullable{Bool}()                    # x null, y == false
            )
        ),
        ifelse( isnull(y),
            ifelse( unsafe_get(x),
                Nullable(true),                     # x == true, y null
                Nullable{Bool}()                    # x == false, y null
            ),
            Nullable(unsafe_get(x) | unsafe_get(y)) # x, y not null
        )
    )
end

# TODO: Decide on semantics for isequal and uncomment the following
# @inline function lift(::typeof(isequal), x, y)
#     return ifelse( isnull(x),
#         ifelse( isnull(y),
#             true,                                   # x, y null
#             false                                   # x null, y not null
#         ),
#         ifelse( isnull(y),
#             false,                                   # x not null, y null
#             isequal(unsafe_get(x), unsafe_get(y))    # x, y not null
#         )
#     )
# end

@inline function lift(::typeof(isless), x, y)::Bool
    if null_safe_op(isless, typeof(x), typeof(y))
        return ifelse( isnull(x),
            false,                                      # x null
            ifelse( isnull(y),
                true,                                   # x not null, y null
                isless(unsafe_get(x), unsafe_get(y))    # x, y not null
            )
        )
    else
        return  isnull(x) ? false :
                isnull(y) ? true  : isless(unsafe_get(x), unsafe_get(y))
    end
end

@inline lift(::typeof(isnull), x) = isnull(x)
@inline lift(::typeof(get), x::Nullable) = get(x)
@inline lift(::typeof(get), x::Nullable, y) = get(x, y)
