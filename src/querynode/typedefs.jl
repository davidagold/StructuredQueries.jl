abstract QueryNode
abstract JoinNode <: QueryNode
typealias QueryArg Union{Symbol, Expr}

"""
Represent a data source in a manipulation graph.

Notes: Any manipulation graph must have a `DataNode` (which may possibly be
empty) as its base.
"""
type DataNode <: QueryNode
    input

    DataNode() = new()
end

function (::Type{DataNode})(x)
    res = DataNode()
    res.input = x
    return res
end

# One-table verbs

"""
"""
type SelectNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{SelectHelper}
    parameters

    function (::Type{SelectNode})(input, args)
        return new(input, args, Vector{SelectHelper}(), Set{Symbol}())
    end
end

"""
"""
type FilterNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{FilterHelper}
    parameters

    function (::Type{FilterNode})(input, args)
        return new(input, args, Vector{FilterHelper}(), Set{Symbol}())
    end
end

"""
"""
type GroupbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{GroupbyHelper}
    parameters

    function (::Type{GroupbyNode})(input, args)
        return new(input, args, Vector{GroupbyHelper}(), Set{Symbol}())
    end
end

"""
"""
type SummarizeNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{SummarizeHelper}
    parameters

    function (::Type{SummarizeNode})(input, args)
        return new(input, args, Vector{SummarizeHelper}(), Set{Symbol}())
    end
end

"""
"""
type OrderbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{SummarizeHelper}
    parameters

    function (::Type{OrderbyNode})(input, args)
        return new(input, args, Vector{OrderbyHelper}(), Set{Symbol}())
    end
end

# Two-table verbs

"""
"""
type LeftJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{LeftJoinHelper}
    parameters

    function (::Type{LeftJoinNode})(input1, input2, args)
        return new(input1, input2, args, Vector{OrderbyHelper}(), Set{Symbol}())
    end
end

"""
"""
type OuterJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{OuterJoinHelper}
    parameters

    function (::Type{OuterJoinNode})(input1, input2, args)
        return new(input1, input2, args, Vector{OuterJoinHelper}(), Set{Symbol}())
    end
end

"""
"""
type InnerJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{InnerJoinHelper}
    parameters

    function (::Type{InnerJoinNode})(input1, input2, args)
        return new(input1, input2, args, Vector{InnerJoinHelper}(), Set{Symbol}())
    end
end

"""
"""
type CrossJoinNode <: JoinNode
    input1::QueryNode
    input2::QueryNode
    args::Vector{QueryArg}
    helpers::Vector{CrossJoinHelper}
    parameters

    function (::Type{CrossJoinNode})(input1, input2, args)
        return new(input1, input2, args, Vector{CrossJoinHelper}(), Set{Symbol}())
    end
end
