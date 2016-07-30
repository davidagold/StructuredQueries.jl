function Base.collect(g::QueryNode)
    has_src(g) || error()
    return _collect(g)
end

_collect(d::DataNode) = d.input
_collect(g::QueryNode) = _collect(_collect(g.input), g)
_collect(::CurryNode, g::QueryNode) = x -> _collect(x, g)
