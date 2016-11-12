abstract QueryNode
abstract JoinNode <: QueryNode
typealias QueryArg Union{Symbol, Expr}

"""
    DataNode <: QueryNode

Represent a data source in a `QueryNode` manipulation graph.

Note: the "leaves" of any `QueryNode` graph must be `DataNode`s.
"""
immutable DataNode{T} <: QueryNode
    input::T
end

immutable Node{V} <: QueryNode
    inputs::Tuple{Vararg{QueryNode}}
    args::Vector{QueryArg}
    dos::Vector{V} # NOTE: the plural of "do" (as a noun...)
end
