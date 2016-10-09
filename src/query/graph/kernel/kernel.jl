"""
"""
function build_kernel_ex!(e::Any, parameters::Set{Symbol})
    tuple_name = gensym()
    s, _parameters = find_symbols(e)
    for p in _parameters
        push!(parameters, p)
    end
    mapping, reverse_mapping = map_symbols(s)
    body_ex = replace_symbols(e, mapping, tuple_name)
    return (
        Expr(:->, tuple_name, Expr(:block, body_ex)),
        reverse_mapping,
    )
end
