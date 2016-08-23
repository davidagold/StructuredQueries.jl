abstract QueryNode
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

"""
"""
has_src(g::QueryNode) = has_src(g.input)
has_src(g::DataNode) = isdefined(g, :input)

"""
"""
set_src!(g::QueryNode, data) = set_src!(g.input, data)
set_src!(g::DataNode, data) = (g.input = data; data)

source(q::QueryNode) = source(q.input)
source(d::DataNode) = d.input

### Helper logic

typealias   NeedsHelper
            Union{
                SelectNode,
                FilterNode,
                GroupbyNode,
                OrderbyNode,
                SummarizeNode
            }


function set_helpers!{T<:NeedsHelper}(g::T, helpers)
    for helper in helpers
        push!(g.helpers, helper)
    end
    helpers
end
set_helpers!(g::QueryNode, helpers) =
    throw(ArgumentError("$(typeof(g)) doesn't need helper."))
