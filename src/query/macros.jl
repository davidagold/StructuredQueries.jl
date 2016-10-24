"""
    @query(qry)

Return a `Query` object that represents the query structure of `qry`.
"""
macro query(qry)
    graph_ex = gen_graph_ex(qry)
    return Expr(:call, Query, graph_ex)
end

"""
    @collect(qry)

Like `@query`, but automatically `collect`s the resulting `Query` object.
"""
macro collect(qry)
    graph_ex = gen_graph_ex(qry)
    return Expr(
        :call, :collect,
        Expr(:call, Query, graph_ex)
    )
end

macro with(ex)
    # index is a map from row token symbols to the index of the respective
    # data in srcs
    # index = Dict{Symbol,Int}()
    # srcs = Vector{Symbol}()
    index = Dict{Symbol, Symbol}()
    # graph_ex = make_graph!(ex, index, srcs)
    body_ex = _body_ex!(ex, index)
    graph_ex = _graph_ex(body_ex, index)
end

# expecting ex of form `src1(token1), ..., srcn(tokenn) do _body end`
# function _body_ex!(ex, index, srcs)
function _body_ex!(ex, index)
    i = 1
    # Only one data source
    if ex.head == :call
        src, token = ex.args[1], ex.args[3]
        @assert isa(src, Symbol) & isa(token, Symbol)
        # index[token] = i
        # push!(srcs, src)
        haskey(index, token) && throw(ArgumentError("Non-distinct row tokens."))
        index[token] = src

        _body = ex.args[2]
        return _body
        # return _graph_ex(_body, index, srcs)
    # multiple data sources
    elseif ex.head == :tuple
        for arg in ex.args
            @assert arg.head == :call
            src = arg.args[1]
            if isa(arg.args[2], Symbol)
                token = arg.args[2]
                # index[token] = i
                # push!(srcs, src)
                haskey(index, token) && throw(ArgumentError("Non-distinct row tokens."))
                index[token] = src
            else
                token = arg.args[3]
                @assert isa(token, Symbol)
                # index[token] = i
                # push!(srcs, src)
                haskey(index, token) && throw(ArgumentError("Non-distinct row tokens."))
                index[token] = src

                # _body is of form Expr(:->, ...) and is second argument
                # because of do syntax
                _body = arg.args[2]
                return _body
            end
        end
    else
        error()
    end
    return
end

# function _graph_ex(_body::Expr, index, srcs)
function _graph_ex(_body::Expr, index)
    @assert _body.head == :->
    @assert length(_body.args[1].args) == 0
    body = _body.args[2]
    @assert body.head == :block

    stash = Dict{Set{Symbol}, Expr}(
        # src => Expr(:call, :(StructuredQueries._leaf), esc(src)) for src in srcs
        Set([src]) => Expr(:call, DataNode, QuoteNode(src)) for src in values(index)
    )

    # for recording which manipulation tracks have merged via joins
    join_hist = Dict{Symbol, Set{Symbol}}(
        src => Set([src]) for src in values(index)
    )
    graph_ex = traverse!(body.args, stash, join_hist, index)
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
        node_ex, srcs_used = build_node_ex!(stash, join_hist, Val{verb}(), args, index)
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
        if ex.head == :return
            _args = ex.args[1]
            if isa(_args, Expr)
                if _args.head == :.
                    args = [_args]
                elseif _args.head == :tuple
                    args = _args.args
                end
            end
        elseif ex.head == :tuple
            args = ex.args
        # TODO: handle assignment, but don't expect a row token
        # elseif ex.head == :(=)
        elseif ex.head == :.
            args = [ex]
        else # now what?
            # maybe throw some error?
        end
        node_ex, srcs_used = build_node_ex!(stash, join_hist, Val{:select}(), args, index)
        return node_ex
    end
end

function build_node_ex!{V}(stash, join_hist, ::Val{V}, args, index)
    # which sources are pertinent to the present verb invocation?
    srcs_used, helpers_ex = process_args(Val{V}(), args, index)
    # build expression to instantiate node for present verb
    src_nodes_ex = Expr(:tuple)
    src_nodes_ex.args = [ stash[join_hist[src]] for src in srcs_used ]
    node_ex = Expr(:call, Node{verb}, src_nodes_ex, args, helpers_ex)
    return node_ex, srcs_used
end

# NOTE: filter is special because we may need to decompose into filter + joins
function build_node_ex!(stash, join_hist, ::Val{:filter}, args, index)
    join_arg_idxs, filter_arg_idxs = Vector{Int}(), Vector{Int}()
    process_args!(stash, join_hist, Val{:filter}(), args, index)
end

"""

The strategy is to sort the args into filters that happen before the join,
join arguments, and filters that happen after the join.
"""
# NOTE: FilterHelper has its own definition because args are processed together
function process_args!(stash, join_hist, ::Val{:filter}, exs, index)::Tuple{Expr, Set{Symbol}}
    # for an early (before join) filter -- i.e., a filters that only concerns a
    # single source -- we don't know join path until we inspect which source is used
    # map a source to a vector of arg, helper_ex tuples
    early_filters = Dict{Symbol, Tuple{Vector{Expr}, Vector{Expr}}}()
    early_srcs_used = Set{Symbol}()

    join_srcs_used = Set{Symbol}()
    join_args = Vector{Expr}()
    join_helpers_ex = Expr(:ref, Helper{:innerjoin})

    # TODO: there may be late filters that join sources not involved in the join!!
    # Take care of those!!!
    # late_filter_srcs_used = Set{Symbol}()
    late_filter_args = Vector{Expr}()
    late_filter_helpers_ex = Expr(:ref, Helper{:filter})

    for ex in exs
        if ex.head == :call && ex.args[1] == :(==)
            verb, srcs_used, helper_ex = join_or_filter!(ex, index)
            if verb == :join
                union!(join_srcs_used, srcs_used)
                push!(join_helpers_ex.args, helper_ex)
                push!(join_args, ex)
            elseif verb == :filter
                if length(srcs_used) == 1 # so, an early filter
                    src = first(srcs_used)
                    (_args, _helper_exs) = get!(
                        early_filters, src,
                        (Vector{Expr}(), Vector{Expr}())
                    )
                    push!(_args, ex)
                    push!(_helper_exs, helper_ex)
                    push!(early_srcs_used, src)
                else
                    push!(late_filter_helpers_ex.args, helper_ex)
                    push!(late_filter_args, ex)
                end
            end
        else # definitely a filter -- is it early or late?
            srcs_used = Set{Symbol}()
            f_ex, arg_fields = build_f_ex!(srcs_used, ex, index)
            helper_ex = Expr(:call, Helper{:filter}, Expr(:tuple, f_ex, arg_fields))
            if length(srcs_used) == 1 # early
                _args, _helper_exs = get!(
                    early_filters, first(srcs_used),
                    (Vector{Expr}(), Vector{Expr}())
                )
                union!(early_srcs_used, srcs_used)
                push!(_args, ex)
                push!(_helper_exs, helper_ex)
            else # late
                push!(late_filter_args, ex)
                push!(late_filter_helpers_ex.args, helper_ex)
            end
        end
    end

    # have any of the sources of the early filters been previously joined?
    # If so, we need to reflect as much in the inputs to the Node{:innerjoin} we
    # construct later
    # map from joins to vectors of args and helper_exs
    hists2nodeparts = Dict{Set{Symbol}, Tuple{Vector{Expr}, Vector{Expr}}}()
    for src in keys(early_filters)
        src_hist = join_hist[src]
        pooled_args, pooled_helper_exs = get!(
            hists2nodeparts, src_hist,
            (Vector{Expr}(), Vector{Expr}())
        )
        args, helper_exs = early_filters[src]
        for (arg, helper_ex) in zip(args, helper_exs)
            push!(pooled_args, arg)
            push!(pooled_helper_exs, helper_ex)
        end
    end

    # If there is no join, assume we can just throw everything in there ...
    if length(join_args) == 0
        src_nodes_ex = Expr(:tuple)
        join_hists = [ join_hist[src] for src in early_srcs_used ]
        # src_nodes_ex.args = [ stash[hist] for hist in join_hists ]
        early_filter_node_ex = Expr(
            :call, Node{:filter}, src_nodes_ex, Vector{Expr}(),
            Expr(:ref, Helper{:filter})
        )
        for hist in join_hists
            push!(src_nodes_ex.args, stash[hist])
            args, helper_exs = hists2nodeparts[hist]
            append!(early_filter_node_ex.args[3], args)
            append!(early_filter_node_ex.args[4].args, helper_exs)
        end
        return early_filter_node_ex, early_srcs_used
    end

    for src_hist in keys(hists2nodeparts)
        node_ex = stash[src_hist]
        args, helper_exs = hists2nodeparts[src_hist]
        helpers_ex = Expr(:ref, Helper{:filter})
        append!(helpers_ex.args, helper_exs)
        stash[src_hist] = Expr(
            :call, Node{:filter}, Expr(:tuple, node_ex), args, helpers_ex
        )
    end

    join_src_nodes_ex = Expr(:tuple)
    for src_hist in [ join_hist[src] for src in join_srcs_used ]
        push!(join_src_nodes_ex.args, stash[src_hist])
    end

    join_node_ex = Expr(
        :call, Node{:innerjoin}, join_src_nodes_ex,
        join_args, join_helpers_ex
    )

    if length(late_filter_args) > 0
        late_filter_node_ex = Expr(
            :call, Node{:filter}, Expr(:tuple, join_node_ex), late_filter_args,
            late_filter_helpers_ex
        )
        return late_filter_node_ex, join_srcs_used
    else
        return join_node_ex, join_srcs_used
    end

    # NOTE: We are assuming here that no late filters mention sources not
    # involved in the join AND that all sources involved in early filters are involved in the join
end

"""
Will mutate `ds` if `ex` is a `filter` expression
"""
function join_or_filter!(ex, index)::Tuple{Symbol, Set{Symbol}, Expr}
    srcs_used1 = Set{Symbol}()
    srcs_used2 = Set{Symbol}()
    lhs, rhs = ex.args[2], ex.args[3]
    # ds1, ds2 = Dict{Symbol, Set{Symbol}}(), Dict{Symbol, Set{Symbol}}()
    f_ex1, arg_fields1 = build_f_ex!(srcs_used1, lhs, index)
    f_ex2, arg_fields2 = build_f_ex!(srcs_used2, rhs, index)
    # if either side cites more than one token,
    # or if the tokens are not equal, join
    if (length(srcs_used1) > 1) | (length(srcs_used2) > 1) | !(isequal(srcs_used1, srcs_used2))
        return :join, union(srcs_used1, srcs_used2),
            Expr(
                :call, Helper{:innerjoin},
                Expr(
                    :tuple, Expr(:tuple, f_ex1, f_ex2),
                    Expr(:tuple, arg_fields1, arg_fields2)
                )
            )
    else # otherwise, filter
        srcs_used = Set{Symbol}()
        f_ex, arg_fields = build_f_ex!(srcs_used, ex, index)
        return :filter, srcs_used,
               Expr(:call, Helper{:filter}, Expr(:tuple, f_ex, arg_fields))
    end
end
