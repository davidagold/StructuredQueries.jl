"""
`Base.isequal(dn1::DataNode, dn2::DataNode)::Bool`

Test two `DataNode`s for equality. This "loose" form of `DataNode` equality is
satisfied when both `dn1` and `dn2` are empty, as in the case of a base
`DataNode` of a `Query` graph that has not yet been `collect`ed against.
"""
function Base.isequal(dn1::DataNode, dn2::DataNode)::Bool
    return ifelse(
        isdefined(dn1, :input),
        isdefined(dn2, :input) ? isequal(dn1.input, dn2.input) : false,
        isdefined(dn2, :input) ? false : true
    )
end

"""
`Base.isequal{T<:QueryNode}(q1::T, q2::T)::Bool`

Test two `QueryNode` objects for equality.

Note that the result depends only on the `input` and `args` fields of each
`q1` and `q2`; the contents of the `helpers` and `parameters` fields are not
compared. This "loose" form of `QueryNode` equality is therefore only
determined by the content of the expression passed to `@query` and reflects the
expectation that the same query (as passed to `@query`) twice should produce
`Query` objects that satisfy `isequal`.
"""
function Base.isequal{T<:QueryNode}(q1::T, q2::T)::Bool
    isequal(q1.input, q2.input) || return false
    isequal(q1.args, q2.args) || return false
    return true
end

"""
`Base.isequal{T<:JoinNode}(q1::T, q2::T)::Bool`

Test two `JoinNode` objects for equality.

This result depends only on the `input1`, `input2` and `args`fields of each `q1`
and `q2`; the contents of the `helpers` and `parameters` fields are not
compared.
"""
function Base.isequal{T<:JoinNode}(q1::T, q2::T)::Bool
    isequal(q1.input1, q2.input2) || return false
    isequal(q1.input2, q2.input2) || return false
    isequal(q1.args, q2.args) || return false
    return true
end

"""
"""
source(q::QueryNode) = source(q.input)
source(q::JoinNode) = (source(q.input1), source(q.input2))
source(d::DataNode) = d.input
