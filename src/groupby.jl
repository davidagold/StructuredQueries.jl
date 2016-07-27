#=
@groupby experiences same issue concerning piped and non-piped data inputs as
does @select. See top of `src/select.jl` for details and current solution
=#
macro groupby(args...)
    input, cols = args[1], args[2:end]
    _input = QuoteNode(input)
    return quote
        try # assume first that first arg is data input
            g = GroupbyNode($(esc(input)), collect($cols))
            run(g.input, g)
        catch err
            #= if error because first arg isn't valid name, assume it is a
            column specification and return curried run. Otherwise, throw
            the error =#
            if err == UndefVarError($_input)
                g = GroupbyNode(DataNode(), collect($args))
                run(CurryNode(), g)
            else
                throw(err)
            end
        end
    end
end

run(::CurryNode, g::GroupbyNode) = x -> run(x, g)
run(input::DataNode, g::GroupbyNode) = run(input.input, g)
run(df::DataFrames.DataFrame, g::GroupbyNode) = groupby(df, g.fields)
