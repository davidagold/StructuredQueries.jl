"""
    jplyr.QUERYNODE
"""
const QUERYNODE = Dict{Symbol, DataType}(
    :filter => FilterNode,
    :select => SelectNode,
    :groupby => GroupbyNode,
    :orderby => OrderbyNode,
    :summarize => SummarizeNode,
    :summarise => SummarizeNode
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
        command = exf(ex)
        args = exfargs(ex)
        if haskey(QUERYNODE, command)
            gen_node!(ex, piped_to, QUERYNODE[command], src)
        elseif command == :|>
            return (gen_graph!(args[1], false, src) |>
                    gen_graph!(args[2], true, src))
        end
    elseif ex.head == :quote
        return DataNode(ex.args[1])
    end
end

function gen_node!(ex, piped_to, T, src)
    args = exfargs(ex)
    input = args[1]
    if !piped_to
        T(gen_graph!(input, false, src), args[2:end])
    else # if piped to, assume all args are conditions
        return x -> T(x, args)
    end
end
