"""
    jplyr.QUERYNODE
"""
const QUERYNODE = Dict{Symbol, DataType}(
    # one-table verbs
    :select => SelectNode,
    :filter => FilterNode,
    :groupby => GroupbyNode,
    :orderby => OrderbyNode,
    :summarize => SummarizeNode,
    :summarise => SummarizeNode,

    # Two-table verbs
    :leftjoin => LeftJoinNode,
    :outerjoin => OuterJoinNode,
    :innerjoin => InnerJoinNode,
    :crossjoin => CrossJoinNode
)

function gen_graph(x)
    src = Vector{Symbol}()
    return src, gen_graph!(x, false, src)
end

function gen_graph!(x::Symbol, piped_to, src)
    isempty(src) && push!(src, x)
    return DataNode()
end

function gen_graph!(ex::Expr, piped_to, src)
    if ex.head == :call
        verb = exf(ex)
        args = exfargs(ex)
        if haskey(QUERYNODE, verb)
            T = QUERYNODE[verb]
            # gen_node!(ex, piped_to, T, ntables(T), src)
            gen_node!(args, piped_to, T, src)
        elseif verb == :|>
            return (gen_graph!(args[1], false, src) |>
                    gen_graph!(args[2], true, src))
        end
    elseif ex.head == :quote
        return DataNode(ex.args[1])
    end
end

function gen_node!{T<:QueryNode}(args, piped_to, ::Type{T}, src)
    # args = exfargs(ex)
    if !piped_to
        input = args[1]
        return T(gen_graph!(input, false, src), args[2:end])
    else # if piped to, assume all args are conditions
        return x -> T(x, args)
    end
end

function gen_node!{T<:JoinNode}(args, piped_to, ::Type{T}, src)
    if !piped_to
        input1 = args[1]
        input2 = args[2]
        return T(
            gen_graph!(input1, false, src),
            gen_graph!(input2, false, src),
            args[3:end]
        )
    else
        input2 = args[1]
        return x -> T(x, gen_graph!(input2, false, src), args[2:end])
    end
end
