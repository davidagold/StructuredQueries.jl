function _build_anon_func(e::Union{Symbol, Expr})
    tpl_name = gensym()
    s = _find_symbols(e)
    mapping, reverse_mapping = _map_symbols(s)
    new_e = _replace_symbols(e, mapping, tpl_name)
    return (
        Expr(:->, tpl_name, Expr(:block, Expr(:line, 1), new_e)),
        reverse_mapping,
    )
end

# TODO: Decide whether to provide both @mutate! vs @mutate macros.
# TODO: Make a copy before mutating the copy.
macro mutate(tbl_name, exprs...)
    insert_exprs = []
    for e in exprs
        col_name = _get_column_name(e)
        core_expr = _get_core_expr(e)
        anon_func_expr, reverse_mapping = _build_anon_func(core_expr)
        insert_expr = Expr(
            :(=),
            Expr(:ref, esc(tbl_name), QuoteNode(col_name)),
            Expr(
                :call,
                :_apply_tuple_func,
                anon_func_expr,
                esc(tbl_name),
                esc(reverse_mapping),
            ),
        )
        push!(insert_exprs, insert_expr)
    end
    return Expr(:block, insert_exprs...)
end
