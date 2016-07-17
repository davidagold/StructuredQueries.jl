# TO DO: Figure out how to run complicated graphs
macro query(qry)
    g = graph(qry)
    return :( $g )
end

#=
Want, for instance, filter(PetalLength > 1.5, Species == "setosa") to go to
    _filter(:(PetalLength > 1.5), :(Species == "setosa"))
=#

exf(ex) = ex.args[1]
exfargs(ex) = ex.args[2:end]

graph(x) = graph(x, false)
graph(x, piped_to) = DataNode(x)
function graph(ex::Expr, piped_to)
    if ex.head == :call
        f = exf(ex)
        args = exfargs(ex)
        if f == :filter
            return graph(ex, piped_to, _filter)
        elseif f == :select
            return graph(ex, piped_to, _select)
        elseif f == :|>
            return (graph(args[1], false) |> graph(args[2], true))
        end
    end
end

function graph(ex, piped_to, method)
    args = exfargs(ex)
    arg1 = args[1]
    if !piped_to
        with_input(arg1, args, method)
    else # if piped to, assume all args are conditions
        return method(args)
    end
end

function with_input(input, args, method)
    if length(args) > 1
        # assume remaining arguments are conditions/columns/whatever
        _args = args[2:end]
    else
        _args = []
    end
    return method(graph(input), _args)
end
