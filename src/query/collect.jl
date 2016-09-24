"""
    Base.collect(qry::Query{Symbol}; sources...)

Collect a `Query` object formed by using a placeholder source in a query.

The symbols used as placeholders in the original `@query` invocation must appear
as keys in the `sources...` keyword arguments. Each respective value should be
the source that will be substituded for the symbol placeholder when the `Query`
is collected.
"""
function Base.collect(qry::Query{Symbol}; sources...)
    source_var, graph = qry.source, qry.graph
    if length(sources) == 0
        msg = "Cannot collect a Query with no source."
        throw(ArgumentError(msg))
    elseif length(sources) == 1
        k, source = sources[1]
        if source_var == k
            set_src!(graph, source)
            return collect(source, graph)
        else
            msg = @sprintf("Undefined source: %s. Check spelling in query.", k)
            throw(ArgumentError(msg))
        end
    else
        msg = "Multi-source queries currently are not supported."
        throw(ArgumentError(msg))
    end
end

"""
    Base.collect{S}(qry::Query{S})

Collect a `qry` against the source wrapped in the base `DataNode` of
`qry.graph`.
"""
function Base.collect{S}(qry::Query{S})
    source, graph = qry.source, qry.graph
    return collect(source, graph)
end

"""
    Base.collect(source, graph::QueryNode)

Collect a query `graph` against a data `source`.

This method has two purposes. The first is to dispatch to the
appropriate `collect` machinery. (The default collection machinery is
"sequential collection" as illustrated in `StructuredQueries._collect`).

The second is to set `source` as the `input` field of the base `DataNode` of
the graph.

Note that graphs are created at macroexpand-time, when the actual source
object is not available. Thus, the base `DataNode` of each graph is initially
left empty, since it must wrap the actual source (and not just the name of the
source as provided in the macro). To obtain the latter behavior, we populate
the base `DataNode`'s `input` field with the query source at run-time.
"""
function Base.collect(source, graph::QueryNode)
    # set the source of the base DataNode of the graph
    set_src!(graph, source)
    _collect(graph)
end

_collect(d::DataNode) = d.input
_collect(g::QueryNode) = _collect(_collect(g.input), g)
