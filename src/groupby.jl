macro groupby(fields...)
    g = _groupby(gensym(), collect(fields))
    return quote
        run($g)
    end
end

_groupby(conds) = x -> _groupby(x, conds)
_groupby(input, conds) = GroupbyNode(input, conds)

run(g::GroupbyNode) = x -> run(x, g)
run(df::DataFrames.DataFrame, g::GroupbyNode) = groupby(df, g.fields)
