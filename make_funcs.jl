function build_anon_func(e::Expr)
    tpl_name = gensym()
    s = find_symbols(e)
    mapping, reverse_mapping = map_symbols(s)
    new_e = replace_symbols(e, mapping, tpl_name)
    return (
        Expr(:->, tpl_name, Expr(:block, Expr(:line, 1), new_e)),
        reverse_mapping,
    )
end

# Demo that maps functions over vectors-of-tuples.
# macro foo(x, e)
#     col_name = get_column_name(e)
#     core_expr = get_core_expr(e)
#     anon_func_expr = build_anon_func(core_expr)
#     res = Expr(:call, :map, anon_func_expr, esc(x))
#     return res
# end

# TODO: Make this modify the table rather than simply generate a new column
macro mutate(tbl_name, e)
    col_name = get_column_name(e)
    core_expr = get_core_expr(e)
    anon_func_expr, reverse_mapping = build_anon_func(core_expr)
    return Expr(
        :call,
        :_apply_tuple_func,
        anon_func_expr,
        esc(tbl_name),
        esc(reverse_mapping),
    )
end
