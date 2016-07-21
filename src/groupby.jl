#=
@groupby experiences same issue concerning piped and non-piped data inputs as
does @select. See top of `src/select.jl` for details and current solution
=#
macro groupby(args...)
    # for case where first arg is data input
    input, cols = args[1], args[2:end]
    _input = QuoteNode(input)
    g1 = _groupby(input, collect(cols))
    # for case where all args are column specifications
    g2 = _groupby(gensym(), collect(args))
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

_groupby(conds) = x -> _groupby(x, conds)
_groupby(input, conds) = GroupbyNode(input, conds)

run(g::GroupbyNode) = x -> run(x, g)
run(df::DataFrames.DataFrame, g::GroupbyNode) = groupby(df, g.fields)
