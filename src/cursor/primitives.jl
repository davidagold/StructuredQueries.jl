"""
    Base.isequal(c1::Cursor, c2::Cursor)::Bool

Test two `Cursor` objects for equality.

This "loose" form of `Cursor` equality is only determined by the content of the
expression passed to `@with` and reflects the expectation that the same query
(as passed to `withquery`) twice should produce `Cursor` objects that satisfy
`isequal`.
"""
function Base.isequal(c1::Cursor, c2::Cursor)::Bool
    isequal(c1.graph, c2.graph) || return false
    return true
end

"""
    source(c::Cursor)

Return the data source(s) over which `c` is to be collected.
"""
source(c::Cursor) = source(c.graph)

# TODO: Better wording of the following
"""
    graph(q::Cursor)

Return the `QueryNode` graph representation of the query that produced `q`.
"""
graph(c::Cursor) = c.graph

"""
    Base.collect(q::Cursor)

Collect a query against the source wrapped in the base `DataNode` of
`q.graph`.
"""
Base.collect(c::Cursor) = collect(c.graph)
