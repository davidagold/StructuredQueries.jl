"""
    Base.isequal(dn1::DataNode, dn2::DataNode)::Bool

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
    Base.isequal{T<:QueryNode}(q1::T, q2::T)::Bool

Test two `QueryNode` objects for equality.

Note that the result depends only on the `input` and `args` fields of each
`q1` and `q2`; the contents of the `helpers` and `parameters` fields are not
compared. This "loose" form of `QueryNode` equality is therefore only
determined by the content of the expression passed to `@query` and reflects the
expectation that the same query (as passed to `@query`) twice should produce
`Query` objects that satisfy `isequal`.
"""
function Base.isequal{T<:Node}(q1::T, q2::T)::Bool
    isequal(q1.inputs, q2.inputs) || return false
    isequal(q1.args, q2.args) || return false
    return true
end

# """
#     Base.isequal{T<:JoinNode}(q1::T, q2::T)::Bool
#
# Test two `JoinNode` objects for equality.
#
# This result depends only on the `input1`, `input2` and `args`fields of each `q1`
# and `q2`; the contents of the `helpers` and `parameters` fields are not
# compared.
# """
# function Base.isequal{T<:JoiNode}(q1::T, q2::T)::Bool
#     isequal(q1.inputs, q2.inputs) || return false
#     isequal(q1.args, q2.args) || return false
#     return true
# end

# TODO: should this flatten?
function source(q::QueryNode)
    inputs = q.inputs
    if length(inputs) > 1
        return tuple([ source(input) for input in inputs ]...)
    else
        return source(first(inputs))
    end
end
source(d::DataNode) = (d.input,)

dos(q::QueryNode) = q.dos

# As a container

function _collect end
function Base.collect(q::Node)
    inputs = tuple([ collect(input) for input in q.inputs ]...)
    return _collect(inputs, q)
end

function prepare end
Base.collect(d::DataNode) = prepare(d.input)
