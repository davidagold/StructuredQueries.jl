"""
    kernel!(e, paramters)

Return an `Expr` to define a (tuple-argument) lambda whose body reflects the
structure of `e`. Also push any query parameters found while traversing `e`
to `parameters`.
"""
function kernel!(e::Any, parameters::Set{Symbol})
    tuple_name = gensym()
    s, _parameters = find_symbols(e)
    for p in _parameters
        push!(parameters, p)
    end
    mapping, reverse_mapping = map_symbols(s)
    body_expression = replace_symbols(e, mapping, tuple_name)
    return (
        Expr(:->, tuple_name, Expr(:block, body_expression)),
        reverse_mapping,
    )
end
