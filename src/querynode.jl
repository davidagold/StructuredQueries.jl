type DataFrame end

abstract QueryNode

immutable DataNode{T} <: QueryNode
    data::T
end

QueryNode(df::DataFrame) = DataNode(df)

immutable FilterNode <: QueryNode
    input::QueryNode
    conds::Vector{Expr}
end

FilterNode(input, ex::Expr...) = FilterNode(input, collect(ex))
FilterNode(input::DataFrame, ex::Expr...) = FilterNode(DataNode(input), collect(ex))

immutable SelectNode <: QueryNode
    input::QueryNode
    cols::Vector{Symbol}
end

exf(ex) = ex.args[1]
exfargs(ex) = ex.args[2:end]
