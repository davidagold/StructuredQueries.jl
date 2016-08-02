macro filter(input::Symbol, _args::Expr...)
    args = collect(_args)
    filter_helper_ex = _build_helper_ex(FilterNode, args)
    #= we need to generate the filtering kernel's definition at macroexpand-time
    so the definition can be spliced into the proper (i.e., original caller's) scope =#
    return quote
        g = FilterNode(DataNode($(esc(input))), $args, $filter_helper_ex)
        _collect(g)
    end
end

# for case in which data source is piped to @filter call
macro filter(_args::Expr...)
    args = collect(_args)
    filter_helper_ex = _build_helper_ex(FilterNode, args)
    return quote
        g = FilterNode(DataNode(), $args, $filter_helper_ex)
        _collect(CurryNode(), g)
    end
end

function _build_helper_ex(::Type{FilterNode}, args)
    kernel_ex, flds = _filter_helper_parts(args)
    return quote
        Helper{FilterNode}([($kernel_ex, $flds)])
    end
end

function _filter_helper_parts(args)
    filter_pred = aggr(args)
    kernel_ex, ind2sym = _build_anon_func(filter_pred)
end

aggr(args) = foldl((x,y)->:($x & $y), args)
