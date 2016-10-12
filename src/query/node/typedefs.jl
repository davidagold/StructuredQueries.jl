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

# One-table verbs

"""
"""
immutable SelectNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{SelectHelper}
end

"""
"""
immutable FilterNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{FilterHelper}
end

"""
"""
immutable GroupbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{GroupbyHelper}
end

"""
"""
immutable SummarizeNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{SummarizeHelper}
end

"""
"""
immutable OrderbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{OrderbyHelper}
end

# Two-table verbs

"""
"""
immutable LeftJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{LeftJoinHelper}
end

"""
"""
immutable OuterJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{OuterJoinHelper}
end

"""
"""
immutable InnerJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{InnerJoinHelper}
end

"""
"""
immutable CrossJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{CrossJoinHelper}
end
