# Case: src[i]
function _srctoken!(index, ex::Expr)::Symbol
    @assert ex.head == :ref
    src, token = ex.args[1], ex.args[2]
    @assert isa(src, Symbol) & isa(token, Symbol)
    # TODO: What happens in case of src[i], src[j]?
    haskey(index, token) && throw(ArgumentError("Non-distinct row tokens."))
    index[token] = src
    index[src] = token
    return src
end

# Case: src
function _srctoken!(index, src::Symbol)::Symbol
    token = gensym()
    in(src, values(index)) && throw(ArgumentError("Non-distinct sources."))
    index[token] = src
    index[src] = token
    return src
end

macro with(srcs, verbs::Expr)
    # We use the same object as a map from tokens to sources and from sources
    # to tokens
    index = Dict{Symbol, Symbol}()
    # extract source/token from each source in srcs
    primary = Nullable{Symbol}()
    if isa(srcs, Expr)
        if srcs.head == :ref
            _srctoken!(index, srcs)
        elseif srcs.head == :tuple
            # foreach(x -> _srctoken!(index, x), srcs.args)
            # the primary source is the first tokenless source
            tokenless = false
            for arg in srcs.args
                src = _srctoken!(index, srcs)
                if !tokenless
                    primary, tokenless = Nullable(src), true
                end
            end
        else
            # TODO: informative error message
            error()
        end
    elseif isa(srcs, Symbol)
        primary = Nullable(_srctoken!(index, srcs))
    end

    # generate graph expression from `verbs`
    if verbs.head == :call
        graph_ex = _graph_ex([verbs], index, primary)
    elseif (verbs.head == :tuple) | (verbs.head == :block)
        graph_ex = _graph_ex(verbs.args, index, primary)
    else
        # TODO: informative error message
        error()
    end
    return quote
        q = $graph_ex
        # @show q
        _with(q, source(q))
    end
end

_with(q::Node, src) = Cursor(q)
