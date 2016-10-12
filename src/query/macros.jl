"""
    @query(qry)

Return a `Query` object that represents the query structure of `qry`.
"""
macro query(qry)
    graph_ex = gen_graph_ex(qry)
    return Expr(:call, :Query, graph_ex)
end

"""
    @collect(qry)

Like `@query`, but automatically `collect`s the resulting `Query` object.
"""
macro collect(qry)
    graph_ex = gen_graph_ex(qry)
    return Expr(
        :call, :collect,
        Expr(:Query, graph_ex)
    )
end
