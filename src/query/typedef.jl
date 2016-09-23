"""
    Query{S}

Wraps a `source::S` and `graph::QueryNode` fields that together represent the
structure of a query passed to the `@query` macro.
"""
type Query{S}
    source::S
    graph::QueryNode
end
