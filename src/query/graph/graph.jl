"""
    QUERYNODE

Internal map from manipulation verb names (as `Symbol`s) to tuples
`(T<:QueryNode, H<:QueryHelper)`.
"""
const QUERYNODE = Dict{Symbol, Tuple{DataType, DataType}}(
    :select => (SelectNode, SelectHelper),
    :filter => (FilterNode, FilterHelper),
    :groupby => (GroupbyNode, GroupbyHelper),
    :orderby => (OrderbyNode, OrderbyHelper),
    :summarize => (SummarizeNode, SummarizeHelper),
    :summarise => (SummarizeNode, SummarizeHelper),

    # <: JoinNode
    :leftjoin => (LeftJoinNode, LeftJoinHelper),
    :outerjoin => (OuterJoinNode, OuterJoinHelper),
    :innerjoin => (InnerJoinNode, InnerJoinHelper),
    :crossjoin => (CrossJoinNode, CrossJoinHelper)
)

_leaf(x) = DataNode(x)
_leaf(q::Query) = q.graph

"""
    graph(qry)::Expr

Return an `Expr` to produce a graph representation of `qry`.
"""
graph(qry)::Expr = graph(qry, false)
graph(src::Symbol, piped_to) =
    Expr(:call, :(StructuredQueries._leaf), esc(src))

function graph(ex::Expr, piped_to)
    if ex.head == :call
        verb = call_function(ex)
        _args = call_function_arguments(ex)
        if haskey(QUERYNODE, verb)
            T, H = QUERYNODE[verb]
            return node(T, H, _args, piped_to)
        elseif verb == :|>
            return graph(_args[1], false) |>
                   graph(_args[2], true)
        end
    else # not valid syntax
        # TODO: informative error message
        error()
    end
end

"""
    node{T}(::Type{T}, H, args, piped_to)

Return an `Expr` to produce a `QueryNode` based on a verb
(corresponding to `T`)/arguments (corresponding to `args`) from a query
expression `qry` in `@query qry`.
"""
function node{T<:QueryNode}(::Type{T}, H, _args, piped_to)
    if !piped_to # first argument is an input
        input = _args[1]
        args = _args[2:end]
        return Expr(
            :call, T,
            graph(input, false),
            args,
            helpers(H, args)
        )
    else # all _args are query args
        return x -> Expr(:call, T, x, _args, helpers(H, _args))
    end
end

function node{T<:JoinNode}(::Type{T}, H, _args, piped_to)
    if !piped_to
        input1 = _args[1]
        input2 = _args[2]
        args = _args[3:end]
        return Expr(
            :call, T,
            graph(input1, false), graph(input2, false),
            args,
            helpers(H, args)
        )
    else
        input2 = _args[1]
        args = _args[2:end]
        return x -> Expr(
            :call, T,
            x, graph(input2, false),
            args,
            helpers(H, args)
        )
    end
end
