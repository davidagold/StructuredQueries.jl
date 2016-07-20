macro groupby()

end

_groupby(conds) = x -> _groupby(x, conds)
_groupby(input, conds) = GroupbyNode(input, conds)
