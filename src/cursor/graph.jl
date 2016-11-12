"""
    QUERYNODE

Internal map from manipulation verb names (as `Symbol`s) to tuples
`(T<:QueryNode, H<:QueryHelper)`.
"""
const VERB = Dict{Symbol, DataType}(
    :select => Select,
    :filter => Filter,
    :groupby => GroupBy,
    :orderby => OrderBy,
    :summarize => Summarize,
    :summarise => Summarize,

    # <: JoinNode
    :leftjoin => LeftJoin,
    :outerjoin => OuterJoin,
    :innerjoin => InnerJoin,
    :join => InnerJoin,
    :crossjoin => CrossJoin,
)

_leaf(x) = DataNode(x)
_leaf(c::Cursor) = c.graph

function _graph_ex(args, index::Dict{Symbol, Symbol})

    stash = Dict{Set{Symbol}, Expr}(
        Set([src]) => Expr(:call, :(StructuredQueries._leaf), esc(src)) for src in values(index)
    )
    # for recording which manipulation tracks have merged via joins
    join_hist = Dict{Symbol, Set{Symbol}}(
        src => Set([src]) for src in values(index)
    )
    graph_ex = traverse!(args, stash, join_hist, index)
    return graph_ex
end

"""

Stores the extant graph in `stash`.
"""
function traverse!(exs, stash, join_hist, index)
    ex = exs[1]
    if ex.head == :line # skip line number Exprs
        return traverse!(exs[2:end], stash, join_hist, index)
    elseif ex.head == :call
        verb, args = ex.args[1], ex.args[2:end]
        V = VERB[verb]
        node_ex, srcs_used = build_node_ex!(stash, join_hist, V, args, index)
        # Have any such sources been joined *together* in previous verbs?
        # If so, they will have matching join_hist values
        srcs_hist = unique([join_hist[src] for src in srcs_used])
        # If we have two or more sources with different join histories,
        # record the join
        joined_srcs = union(srcs_hist...)
        foreach(src->(join_hist[src] = joined_srcs), joined_srcs)
        stash[joined_srcs] = node_ex
        if length(exs) > 1 # more verbs to go
            return traverse!(exs[2:end], stash, join_hist, index)
        else
            return node_ex # no more verbs, return graph expression
        end
    else # Each following case is parsed as a select
        args = Vector{Expr}()
        if ex.head == :return
            _args = ex.args[1]
            if isa(_args, Expr)
                if _args.head == :tuple # multiple column selections
                    append!(args, _args.args)
                else
                    # assume a single column selection
                    # TODO: handle things
                    push!(args, _args)
                end
            else # ???
            end
        elseif ex.head == :tuple # multiple column selections
            append!(args, ex.args) # TODO: handle assignments...
        # TODO: handle assignment, but don't expect a row token
        # elseif ex.head == :(=)
        else
            # TODO: check for validity ...
            push!(args, ex)
        end
        node_ex, srcs_used = build_node_ex!(stash, join_hist, Select, args, index)
        return node_ex
    end
end

function build_node_ex!{V}(stash, join_hist, ::Type{V}, args, index)
    # process args into Verb instances
    # which sources are pertinent to the present verb invocation?
    srcs_used, helpers_ex = process_args(V, args, index)
    # If no declared sources are used in any verbs, throw an error
    isempty(srcs_used) && throw(ArgumentError("No declared sources used in verbs."))
    # build expression to instantiate node for present verb
    src_nodes_ex = Expr(:tuple)
    unique_src_hists = unique([ join_hist[src] for src in srcs_used ])
    append!(src_nodes_ex.args, [ stash[src_hist] for src_hist in unique_src_hists ])
    node_ex = Expr(:call, Node{V}, src_nodes_ex, args, helpers_ex)
    # node_ex = Expr(:call, :(StructuredQueries._with), Expr(:call, Q, src_nodes_ex, args, helpers_ex))
    return node_ex, srcs_used
end
