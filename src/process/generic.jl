"""
    process_graph!(g)

Process a `QueryNode` graph by (i) building `QueryHelper`-creating expressions;
(ii) identifying and processing unbound query parameters.

Returns an expression that mutates each `QueryNode` node of the graph `g` by
"""
function process_graph!(g)::Expr
    push!_helpers_ex = Expr(:block)
    process_node!(g, push!_helpers_ex)
    return push!_helpers_ex
end

process_node!(g::DataNode, set_helpers!_ex)::Void = nothing

"""
`process_node!(q::QueryNode, set_helpers!_ex)`

Push expressions that generate `QueryHelper`s to the `args` field of
`set_helpers!_ex`.

Recursively acts on the graph of `QueryNode`s of which `q` is a part.
"""
function process_node!(q::QueryNode, push!_helpers_ex)::Void
    for arg in q.args
        push!_helper_ex = process_arg!(q, arg)
        push!(
            push!_helpers_ex.args,
            push!_helper_ex
        )
    end
    process_node!(q.input, push!_helpers_ex)
    return
end

function process_node!(q::JoinNode, push!_helpers_ex)::Void
    for arg in q.args
        push!_helper_ex = process_arg!(q, arg)
        push!(
            push!_helpers_ex.args,
            push!_helper_ex
        )
    end
    process_node!(q.input1, push!_helpers_ex)
    process_node!(q.input2, push!_helpers_ex)
    return
end

"""
    process_arg(q, e)

(i) Return an expression that creates a `QueryHelper` object and (ii) identify
unbound parameters in `e` and include them into the `parameters` field of `q`.
"""
function process_arg end
