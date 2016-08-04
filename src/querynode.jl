abstract QueryNode
abstract QueryHelper
typealias QueryArg Union{Symbol, Expr}

"""
Represent a data source in a manipulation graph.

Notes: Any manipulation graph must have `DataNode` (which may possibly be
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


# TODO: clarify the following explanation.
"""
A `Helper{T<:QueryNode}` wraps a collection of objects that are used during the
execution of a node of type `T` over an `AbstractTable`. Some of these objects
-- in particular, row-wise kernels -- rely on processing that must be performed
at macroexpand-time. Since the type of a manipulation graph's base data source
is not known at macroexpand-time, these objects must be produced regardless of
whether or not the base data source is an `AbstractTable`. `Helper`s store
these objects for use in case the base data source is indeed an `AbstractTable`.
"""
type Helper{T} <: QueryHelper
    parts::Vector{Tuple}
end

"""
Represent a filter operation in a manipulation graph.

Fields:

* `input::QueryNode`: a node representing either a data source or preceding
manipulation
* `args::Vector{Expr}`: a vector of filtering expressions
* `helper::FilterHelper`: a helper for run-time execution of the `FilterNode`
over an `AbstractTable`
"""
type FilterNode <: QueryNode
    input::QueryNode
    args::Vector{Expr}
    helper::Helper{FilterNode}

    FilterNode(input, conds) = new(input, conds)
end

type SelectNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

type GroupbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

type OrderbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

type MutateNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helper::Helper{MutateNode}

    (::Type{MutateNode})(input, args) = new(input, args)
end

# TODO: think about what sort of information would be useful to store in `args`.
type SummarizeNode <: QueryNode
    input::QueryNode
    args::Vector{Expr}
    helper::Helper{SummarizeNode}

    (::Type{SummarizeNode})(input, args) = new(input, args)
end

immutable CurryNode end

for T in (:FilterNode, :MutateNode, :SummarizeNode)
    @eval function (::Type{$T})(input, conds, helper)
        res = $T(input, conds)
        set_helper!(res, helper)
        return res
    end
end

has_src(g::QueryNode) = has_src(g.input)
has_src(g::DataNode) = isdefined(g, :input)
set_src!(g::QueryNode, data) = set_src!(g.input, data)
set_src!(g::DataNode, data) = (g.input = data; data)

typealias NeedsHelper Union{FilterNode, MutateNode, SummarizeNode}

has_helper(g::NeedsHelper) = isdefined(g, :helper)
# Diagonal dispatch buys us some safety
function set_helper!{T<:NeedsHelper}(g::T, helper::Helper{T})
    g.helper = helper
    return helper
end
# if a QueryNode doesn't need a helper, then no-op
set_helper!(g::QueryNode, helper) = helper
