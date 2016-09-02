"""
"""
macro query(qry)
    src, g = gen_graph(qry)
    # process the graph to identify parameters and build QueryHelper exprs
    set_helpers!_ex = process_graph!(g)
    if isempty(src) # if we found a placeholder source (designated by a symbol)
        src_name = QuoteNode(source(g))
    else # otherwise, there's an actual source
        src_name = src[1]
    end
    return quote
        $set_helpers!_ex
        Query($(esc(src_name)), $g)
    end
end

"""
"""
macro collect(qry)
    src, g = gen_graph(qry)
    set_helpers!_ex = process_graph!(g)
    if isempty(src) # if we found a placeholder source (designated by a symbol)
        src_name = QuoteNode(source(g))
    else # otherwise, there's an actual source
        src_name = src[1]
    end
    return quote
        $set_helpers!_ex
        collect(Query($(esc(src_name)), $g))
    end
end
