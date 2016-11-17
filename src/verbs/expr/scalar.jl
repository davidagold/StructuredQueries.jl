"""
    build_kernel_ex!(e, paramters)

Return an `Expr` to define a (tuple-argument) lambda whose body reflects the
structure of `e`.
"""
# function build_f_ex!(ex::Any, ds, index)::Tuple{Expr, Dict{Symbol, Vector{Symbol}}}
function build_f_ex!(srcs_used, ex::Any, index, primary)::Tuple{Expr, ArgsIndex}
    # ai is essentially a map from tokens (and hence sources) to sets of fields cited
    ai = ArgsIndex()
    body_ex = replace_symbols!(ai, ex, index, primary)
    # record which sources were used
    union!(srcs_used, [index[token] for token in keys(ai.index) ])
    args_ex = Expr(:tuple)
    _args = Vector{Symbol}(length(ai.index))
    for t in keys(ai.index)
        _args[1] = t
    end
    append!(args_ex.args, _args)
    return Expr(:->, args_ex, Expr(:block, body_ex)), ai
end
