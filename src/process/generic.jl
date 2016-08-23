"""
Processing a graph entails: (i) building `QueryHelper`-creating expressions;
(ii) identifying and processing unbound query parameters.
"""
function process_graph!(g)
    set_helpers!_ex = Expr(:block)
    return process_node!(g, set_helpers!_ex)
end

process_node!(g::DataNode, set_helpers!_ex) = set_helpers!_ex

"""
Processing a `QueryArg` of a `SelectNode` consists of (i) building an
expression that creates a `SelectHelper` object; and (ii) identifying and
processing any unbound parameters.
"""
function process_node!(g::QueryNode, set_helpers!_ex)
    helpers_ex = _process_node!(g)
    push!(set_helpers!_ex.args,
          :( set_helpers!($g, $helpers_ex) )
    )
    return process_node!(g.input, set_helpers!_ex)
end
