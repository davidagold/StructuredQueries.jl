function _query(qry)
    src, g = gen_graph(qry)
    # process the graph to identify parameters and build QueryHelper exprs
    push!_helpers_ex = process_graph!(g)
    if isempty(src) # if we found a placeholder source (designated by a symbol)
        src_name = QuoteNode(source(g))
    else # otherwise, there's an actual source
        src_name = src[1]
    end
    return push!_helpers_ex, src_name, g
end

"""
    @query(qry)

Return a `Query{S}` object that represents the query structure of `qry`.
"""
macro query(qry)
    push!_helpers_ex, src_name, g = _query(qry)
    return quote
        $push!_helpers_ex
        Query($(esc(src_name)), $g)
    end
end

"""
    @collect(qry)

Like `@query`, but automatically `collect`s the resulting `Query` object.
"""
macro collect(qry)
    push!_helpers_ex, src_name, g = _query(qry)
    return quote
        $push!_helpers_ex
        collect(Query($(esc(src_name)), $g))
    end
end
