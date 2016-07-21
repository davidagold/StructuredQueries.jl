#=
OPEN QUESTION: How to differentiate b/w piped to and non-piped to
@select calls. The issue is how to distinguish a symbol that represents a
data source argument from a symbol that represents a column specification.
The following is one way to do so. However, this strategy will fail/give
incorrect results in cases such as the following:

df |> @select(fieldname)

where `df` and `fieldname` are both valid names bound to DataFrame objects.
=#
macro select(args...)
    # for case where first arg is data input
    input, cols = args[1], args[2:end]
    _input = QuoteNode(input)
    g1 = _select(input, collect(cols))
    # for case where all args are column specifications
    g2 = _select(gensym(), collect(args))
    return quote
        try # assume first that first arg is data input
            run($(esc(input)), $g1)
        catch err
            #= if error because first arg isn't valid name, assume it is a
            column specification and return curried run. Otherwise, throw
            the error =#
            if err == UndefVarError($_input)
                run($g2)
            else
                throw(err)
            end
        end
    end
end

_select(fields) = x -> _select(x, fields)
_select(input, fields) = SelectNode(input, fields)

run(g::SelectNode) = x -> run(x, g)
run(df::DataFrames.DataFrame, g::SelectNode) = df[g.fields]
