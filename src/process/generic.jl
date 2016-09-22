"""
Processing a graph entails: (i) building `QueryHelper`-creating expressions;
(ii) identifying and processing unbound query parameters.
"""
function process_graph!(g)::Expr
    set_helpers!_ex = Expr(:block)
    process_node!(g, set_helpers!_ex)
    return set_helpers!_ex
end

process_node!(g::DataNode, set_helpers!_ex)::Void = nothing

"""
"""
function process_node!(q::QueryNode, set_helpers!_ex)::Void
    helpers_ex = _process_node!(q)
    push!(set_helpers!_ex.args,
          :( set_helpers!($q, $helpers_ex) )
    )
    process_node!(q.input, set_helpers!_ex)
    return
end

function process_node!(q::JoinNode, set_helpers!_ex)::Void
    helpers_ex = _process_node!(q)
    push!(set_helpers!_ex.args,
          :( set_helpers!($q, $helpers_ex) )
    )
    process_node!(q.input1, set_helpers!_ex)
    process_node!(q.input2, set_helpers!_ex)
    return
end
