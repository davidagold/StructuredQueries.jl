# to avoid dispatch overlap with Base methods for filter, select
immutable QueryArg{T}
    arg::T
end

Base.convert{T}(::Type{T}, arg::QueryArg{T}) = arg.arg

macro query(qry)
    piped = pipedsource(qry)
    return quote
        $(esc(resolve(qry, $piped)))
    end
end

function pipedsource(qry)
    if qry.head == :call
        qry.args[1] == :|> ? true : false
    else
        false
    end
end

#= Want, for instance, filter(PetalLength > 1.5, Species == "setosa")
to go to
    filter(:(PetalLength > 1.5), :(Species == "setosa"))
=#

function resolve_filter(ex)
    args = exfargs(ex)
    arg1 = args[1]
    # heuristic for whether or not a data source is passed, or just filter conditions
    # TO-DO: come up with better heuristic --- this will FAIL inside a local scope
    if isa(arg1, Symbol) && isdefined(arg1)
        with_first(args, arg1, :filter, Expr)
    # otherwise, assume all arguments are filter conditions
    else
        conds = QueryArg{Expr}[ QueryArg(cond) for cond in args ]
        return quote
            filter($conds)
        end
    end
end

function resolve_select(ex)
    args = exfargs(ex)
    arg1 = args[1]
    if isa(arg1, Symbol) && isdefined(arg1)
        with_first(args, arg1, :select, Symbol)
    else
        cols = QueryArg{Symbol}[ QueryArg(col) for col in args ]
        return quote
            select($cols)
        end
    end
end

function with_first(args, input, method, T)
    if length(args) > 1
        # assume remaining arguments are conditions/columns/whatever
        args = QueryArg{T}[ QueryArg(arg) for arg in args[2:end] ]
    else
        args = QueryArg{T}[]
    end
    # let dispatch resolve matter of first argument
    return Expr(:call, method, input, args)
end

resolve(x) = x
function resolve(ex::Expr, piped)
    if ex.head == :call
        f = exf(ex)
        if f == :filter
            return resolve_filter(ex, piped)
        elseif f == :select
            return resolve_select(ex, piped)
        elseif exf(ex) == :|>
            return Expr(:call, :|>, [ resolve(arg) for arg in exfargs(ex) ]...)
        end
    else
        return ex
    end
end
