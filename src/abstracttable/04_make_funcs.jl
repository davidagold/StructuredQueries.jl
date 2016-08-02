function _build_anon_func(e::Union{Symbol, Expr})
    tpl_name = gensym()
    s = _find_symbols(e)
    sym2ind, ind2sym = _map_symbols(s)
    new_e = _replace_symbols(e, sym2ind, tpl_name)
    return (
        Expr(:->, tpl_name, Expr(:block, Expr(:line, 1), new_e)),
        ind2sym,
    )
end
