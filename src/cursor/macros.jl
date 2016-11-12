function _srctoken!(index, ex::Expr)::Void
    @assert ex.head == :ref
    src, token = ex.args[1], ex.args[2]
    @assert isa(src, Symbol) & isa(token, Symbol)
    haskey(index, token) && throw(ArgumentError("Non-distinct row tokens."))
    index[token] = src
    return
end

function _srctoken!(index, src::Symbol)::Void
    token = gensym()
    in(src, values(index)) && throw(ArgumentError("Non-distinct sources."))
    index[token] = src
    return
end

macro with(srcs, verbs::Expr)
    index = Dict{Symbol, Symbol}()
    # extract source/token from each source in srcs
    if isa(srcs, Expr)
        if srcs.head == :ref
            _srctoken!(index, srcs)
        elseif srcs.head == :tuple
            foreach(x -> _srctoken!(index, x), srcs.args)
        else
            # TODO: informative error message
            error()
        end
    # elseif isa(srcs, Symbol)
    #     _srctoken!(index, srcs)
    end

    # generate graph expression from `verbs`
    if verbs.head == :call
        graph_ex = _graph_ex([verbs], index)
    elseif (verbs.head == :tuple) | (verbs.head == :block)
        graph_ex = _graph_ex(verbs.args, index)
    else
        # TODO: informative error message
        error()
    end
    return quote
        q = $graph_ex
        @show q
        _with(q, source(q))
    end
end

_with(q::Node, src) = Cursor(q)
