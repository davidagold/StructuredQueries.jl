abstract QueryNode
abstract QueryHelper

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
    fields::Set{Symbol}
end

type FilterNode <: QueryNode
    input::QueryNode
    conds::Vector{Expr}
    hlpr::FilterHelper

    FilterNode(input, conds) = new(input, conds)
end

function (::Type{FilterNode})(input, conds, hlpr)
    res = FilterNode(input, conds)
    res.hlpr = hlpr
    return res
end

has_hlpr(g::FilterNode) = isdefined(g, :hlpr)
set_hlpr!(g::FilterNode, hlpr::FilterHelper) = (g.hlpr = hlpr; return hlpr)

immutable SelectNode <: QueryNode
    input::QueryNode
    fields::Vector{Symbol}
end

immutable GroupbyNode <: QueryNode
    input::QueryNode
    fields::Vector{Symbol}
end

immutable CurryNode end

typealias DataSource Union{DataFrames.DataFrame}

for T in (:FilterNode, :SelectNode, :GroupbyNode)
    @eval (::Type{$T})(input::DataSource, xs...) = $T(DataNode(input), xs...)
end

has_src(g::QueryNode) = has_src(g.input)
has_src(g::DataNode) = isdefined(g, :input)
set_src!(g::QueryNode, data) = set_src!(g.input, data)
set_src!(g::DataNode, data) = (g.input = data; data)
