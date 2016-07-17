macro filter(input::Symbol, conds::Expr...)
    g = _filter(input, collect(conds))
    f, fdef, fields = resolve(g)
    #= we need to generate the filtering kernel's definition at macroexpand-time
    so it can be spliced into the proper (i.e., original caller's) scope =#
    return quote
        $f = $fdef
        run($(esc(input)), $g, $f, $fields)
    end
end

# for case in which data source is piped to @filter call
macro filter(conds::Expr...)
    g = _filter(gensym(), collect(conds))
    f, fdef, fields = resolve(g)
    return quote
        $f = $fdef
        run($g, $f, $fields)
    end
end

_filter(conds) = x -> _filter(x, conds)
_filter(input, conds) = FilterNode(input, conds)

run(g::FilterNode, f, fields) = x -> run(x, g, f, fields)
# wrap in if statement so I don't have to load DataFrames everytime I reload this module
if isdefined(Main, :DataFrame)
    function run(df::Main.DataFrames.DataFrame, g::FilterNode, f, fields)
        cols = [ df[field] for field in fields ]
        rows = bitbroadcast(f, cols...)
        df[rows, :]
    end
end
