macro filter(input::Symbol, _args::Expr...)
    args = collect(_args)
    g = FilterNode(DataNode(), args)
    helper_ex = _build_helper_ex(g)
    return quote
        set_helper!($g, $helper_ex)
        _collect($(esc(input)), $g)
    end
end

# for case in which data source is piped to @filter
macro filter(_args::Expr...)
    args = collect(_args)
    g = FilterNode(DataNode(), args)
    helper_ex = _build_helper_ex(g)
    return quote
        set_helper!($g, $helper_ex)
        _collect(CurryNode(), $g)
    end
end

function _build_helper_ex(g::FilterNode)
    kernel_ex, flds = _build_helper_parts(g)
    return quote
        Helper{FilterNode}([($kernel_ex, $flds)])
    end
end

function _build_helper_parts(g::FilterNode)
    filter_pred = aggregate(g.args)
    kernel_ex, ind2sym = _build_anon_func(filter_pred)
end

aggregate(args) = foldl((x,y)->:($x & $y), args)
