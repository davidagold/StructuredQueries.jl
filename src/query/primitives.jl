"""
    Base.isequal(qry1::Query, qry2::Query)::Bool

Test two `Query` objects for equality. This "loose" form of `Query` equality
is only determined by the content of the expression passed to `@query` and
reflects the expectation that the same query (as passed to `@query`) twice
should produce `Query` objects that satisfy `isequal`.
"""
function Base.isequal(qry1::Query, qry2::Query)::Bool
    isequal(qry1.source, qry2.source) || return false
    isequal(qry1.graph, qry2.graph) || return false
    return true
end
