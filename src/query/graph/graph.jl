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
    gen_graph_ex(qry)::Expr

Return an `Expr` to produce a graph representation of `qry`.
"""
gen_graph_ex(qry)::Expr = gen_graph_ex(qry, false)
gen_graph_ex(src::Symbol, piped_to) =
    Expr(:call, :(StructuredQueries._leaf), esc(src))

function gen_graph_ex(ex::Expr, piped_to)
    if ex.head == :call
        verb = exf(ex)
        _args = exfargs(ex)
        if haskey(QUERYNODE, verb)
            T, H = QUERYNODE[verb]
            return gen_node_ex(T, H, _args, piped_to)
        elseif verb == :|>
            return gen_graph_ex(_args[1], false) |>
                   gen_graph_ex(_args[2], true)
        end
    else # not valid syntax
        # TODO: informative error message
        error()
    end
end

"""
    gen_node_ex{T}(::Type{T}, H, args, piped_to)

Return an `Expr` to produce a `QueryNode` based on a verb
(corresponding to `T`)/arguments (corresponding to `args`) from a query
expression `qry` in `@query qry`.
"""
function gen_node_ex{T<:QueryNode}(::Type{T}, H, _args, piped_to)
    if !piped_to # first argument is an input
        input = _args[1]
        args = _args[2:end]
        return Expr(
            :call, T,
            gen_graph_ex(input, false),
            args,
            gen_helpers_ex(H, args)
        )
    else # all _args are query args
        return x -> Expr(:call, T, x, _args, gen_helpers_ex(H, _args))
    end
end

function gen_node_ex{T<:JoinNode}(::Type{T}, H, _args, piped_to)
    if !piped_to
        input1 = _args[1]
        input2 = _args[2]
        args = _args[3:end]
        return Expr(
            :call, T,
            gen_graph_ex(input1, false), gen_graph_ex(input2, false),
            args,
            gen_helpers_ex(H, args)
        )
    else
        input2 = _args[1]
        args = _args[2:end]
        return x -> Expr(
            :call, T,
            x, gen_graph_ex(input2, false),
            args,
            gen_helpers_ex(H, args)
        )
    end
end
