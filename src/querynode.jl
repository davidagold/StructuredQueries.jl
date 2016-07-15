abstract QueryNode

immutable DataNode{T} <: QueryNode
    data::T
end

immutable FilterNode <: QueryNode
    input::QueryNode
    ex::Vector{Expr}
end

FilterNode(input, ex::Expr...) = FilterNode(input, collect(ex))

immutable SelectNode <: QueryNode
    input::QueryNode
    cols::Vector{Symbol}
end

type DataFrame end

exf(ex) = ex.args[1]
exfargs(ex) = ex.args[2:end]
