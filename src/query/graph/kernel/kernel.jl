"""
    build_kernel_ex!(e, paramters)

Return an `Expr` to define a (tuple-argument) lambda whose body reflects the
structure of `e`.
"""
# function build_f_ex!(ex::Any, ds, index)::Tuple{Expr, Dict{Symbol, Vector{Symbol}}}
function build_f_ex!(srcs_used, ex::Any, index)::Expr
    # tuple_name = gensym()
    # srcs = Set{Symbol}()
    # ds = Dict{Symbol, Set{Symbol}}()
    # find_symbols!(ds, srcs_used, ex, index)
    # maps, reverse_maps = map_symbols(ds)
    arg_tokens = Set{Symbol}()
    body_ex = replace_symbols!(arg_tokens, ex, index)
    union!(srcs_used, [index[token] for token in arg_tokens ])
    args_ex = Expr(:tuple)
    append!(args_ex.args, arg_tokens)
    return Expr(:->, args_ex, Expr(:block, body_ex))
end
