"""
    Base.collect(q::Query)

Collect a `qry` against the source wrapped in the base `DataNode` of
`qry.graph`.
"""
Base.collect(q::Query) = collect(_collect(q.graph))

_collect(d::Tuple{DataNode}) = (d[1].input,)
_collect(q::QueryNode) = _collect(_collect(q.inputs), q)
