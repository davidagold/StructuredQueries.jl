abstract QueryNode
abstract QueryHelper
typealias QueryArg Union{Symbol, Expr}

type DataNode <: QueryNode
    input

    DataNode() = new()
end

function (::Type{DataNode})(x)
    res = DataNode()
    res.input = x
    return res
end

type FilterHelper <: QueryHelper
    kernel
    flds
end

type FilterNode <: QueryNode
    input::QueryNode
    args::Vector{Expr}
    helper::FilterHelper

    FilterNode(input, conds) = new(input, conds)
end

immutable SelectNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

immutable GroupbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

immutable OrderbyNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
end

type MutateHelper <: QueryHelper
    helpers
end

(::Type{MutateHelper})(helpers...) = MutateHelper(collect(helpers))

type MutateNode <: QueryNode
    input::QueryNode
    args::Vector{QueryArg}
    helper::MutateHelper

    (::Type{MutateNode})(input, args) = new(input, args)
end

type SummarizeHelper <: QueryHelper
    parts
end

type SummarizeNode <: QueryNode
    input::QueryNode
    args::Vector{Expr}
    helper::SummarizeHelper

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
const _helper_types = Dict{DataType, DataType}(
    FilterNode => FilterHelper,
    MutateNode => MutateHelper,
    SummarizeNode => SummarizeHelper
)

has_helper(g::NeedsHelper) = isdefined(g, :helper)
function set_helper!{T<:NeedsHelper, S}(g::T, helper::S)
    @assert _helper_types[T] == S
    g.helper = helper
    return helper
end
