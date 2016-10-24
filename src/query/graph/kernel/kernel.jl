"""
    build_kernel_ex!(e, paramters)

Return an `Expr` to define a (tuple-argument) lambda whose body reflects the
structure of `e`.
"""
# function build_f_ex!(ex::Any, ds, index)::Tuple{Expr, Dict{Symbol, Vector{Symbol}}}
function build_f_ex!(srcs_used, ex::Any, index)::Tuple{Expr, Dict{Symbol, Vector{Symbol}}}
    # tuple_name = gensym()
    # srcs = Set{Symbol}()
    ds = Dict{Symbol, Set{Symbol}}()
    find_symbols!(ds, srcs_used, ex, index)
    maps, reverse_maps = map_symbols(ds)
    args_ex = Expr(:tuple)
    args_ex.args = [ token for token in keys(maps) ]
    body_ex = replace_symbols(ex, maps)
    return Expr(:->, args_ex, Expr(:block, body_ex)), reverse_maps
end
