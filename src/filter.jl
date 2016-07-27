macro filter(input::Symbol, _conds::Expr...)
    # g = _filter(input, collect(conds))
    conds = collect(_conds)
    f, fdef, fields = resolve_filter(conds)
    #= we need to generate the filtering kernel's definition at macroexpand-time
    so the definition can be spliced into the proper (i.e., original caller's) scope =#
    return quote
        $f = $fdef
        hlpr = FilterHelper($f, $fields)
        g = FilterNode($(esc(input)), $conds, hlpr)
        _collect(g)
    end
end

# for case in which data source is piped to @filter call
macro filter(_conds::Expr...)
    conds = collect(_conds)
    f, fdef, fields = resolve_filter(conds)
    return quote
        $f = $fdef
        hlpr = FilterHelper($f, $fields)
        g = FilterNode(DataNode(), $conds, hlpr)
        _collect(CurryNode(), g)
    end
end
