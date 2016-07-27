function Base.collect(g::QueryNode)
    has_src(g) || error()
    return _collect(g)
end

_collect(d::DataNode) = d.input
_collect(g::QueryNode) = _collect(_collect(g.input), g)
_collect(::CurryNode, g::QueryNode) = x -> _collect(x, g)

# The following are implementations for concrete data sources 

_collect(df::DataFrames.DataFrame, g::SelectNode) = df[g.fields]
_collect(df::DataFrames.DataFrame, g::GroupbyNode) = groupby(df, g.fields)
function _collect(df::DataFrames.DataFrame, g::FilterNode)
    hlpr = g.hlpr
    cols = [ df[field] for field in hlpr.fields ]
    rows = bitbroadcast(hlpr.kernel, cols...)
    return df[rows, :]
end
