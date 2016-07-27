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
    input, cols = args[1], args[2:end]
    _input = QuoteNode(input)
    return quote
        try # assume first that first arg is data input
            g = SelectNode($(esc(input)), collect($cols))
            run(g.input, g)
        catch err
            #= if error because first arg isn't valid name, assume it is a
            column specification and return curried run. Otherwise, throw
            the error =#
            if err == UndefVarError($_input)
                g = SelectNode(DataNode(), collect($args))
                run(CurryNode(), g)
            else
                throw(err)
            end
        end
    end
end

run(::CurryNode, g::SelectNode) = x -> run(x, g)
run(input::DataNode, g::SelectNode) = run(input.input, g)
run(df::DataFrames.DataFrame, g::SelectNode) = df[g.fields]
