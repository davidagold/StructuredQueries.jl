#=
TO DO: figure out how to differentiate b/w piped to and non-piped to
@select calls. Currently, only the former are handled. The issue is how to
distinguish a symbol that represents a data source argument from a symbol
that represents a field name argument
=#
macro select(syms...)
    g = _select(gensym(), collect(syms))
    return quote
        run($g)
    end
end

_select(fields) = x -> _select(x, fields)
_select(input, fields) = SelectNode(input, fields)

run(g::SelectNode) = x -> run(x, g)
if isdefined(Main, :DataFrame)
    run(df::Main.DataFrames.DataFrame, g::SelectNode) = df[g.fields]
end
