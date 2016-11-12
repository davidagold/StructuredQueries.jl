"""
    Base.isequal(qry1::Query, qry2::Query)::Bool

Test two `Query` objects for equality.

This "loose" form of `Query` equality is only determined by the content of the
expression passed to `@query` and reflects the expectation that the same query
(as passed to `@query`) twice should produce `Query` objects that satisfy
`isequal`.
"""
function Base.isequal(c1::Cursor, c2::Cursor)::Bool
    isequal(c1.graph, c2.graph) || return false
    return true
end

"""
    source(q::Query)

Return the data source(s) against which `q` is to be collected.
"""
source(c::Cursor) = source(c.graph)

# TODO: Better wording of the following
"""
    graph(q::Query)

Return the `QueryNode` graph representation of the query that produced `q`.
"""
graph(c::Cursor) = c.graph

"""
    Base.collect(q::Query)

Collect a query against the source wrapped in the base `DataNode` of
`q.graph`.
"""
Base.collect(c::Cursor) = collect(c.graph)
