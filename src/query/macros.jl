"""
    @query(qry)

Return a `Query` object that represents the query structure of `qry`.
"""
macro query(qry)
    graph_expression = graph(qry)
    return Expr(:call, Query, graph_expression)
end

"""
    @collect(qry)

Like `@query`, but automatically `collect`s the resulting `Query` object.
"""
macro collect(qry)
    graph_expression = graph(qry)
    return Expr(
        :call, :collect,
        Expr(:call, Query, graph_expression)
    )
end
