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
    # @show graph_ex
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
        # which sources are pertinent to the present verb invocation?
        srcs_used, helpers_ex = process_args(Val{verb}(), args, index)
        # build expression to instantiate node for present verb
        src_nodes_ex = Expr(:tuple)
        src_nodes_ex.args = [ stash[join_hist[src]] for src in srcs_used ]
        node_ex = Expr(:call, Node{verb}, src_nodes_ex, args, helpers_ex)
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
        # elseif ex.head == :=
        elseif ex.head == :.
            args = [ex]
        else # now what?
            # throw some error
        end
        srcs_used, helpers_ex = process_args(Val{:select}(), args, index)
        src_nodes_ex = Expr(:tuple)
        src_nodes_ex.args = [ stash[join_hist[src]] for src in srcs_used ]
        node_ex = Expr(:call, Node{:select}, src_nodes_ex, args, helpers_ex)
        return node_ex
    end
end
