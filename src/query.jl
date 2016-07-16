# to avoid dispatch overlap with Base methods for filter, select
immutable QueryArg{T}
    arg::T
end

Base.convert{T}(::Type{T}, arg::QueryArg{T}) = arg.arg

macro query(qry)
    _qry = esc(resolve(qry))
    return :( run($_qry) )
end

#=
Want, for instance, filter(PetalLength > 1.5, Species == "setosa") to go to
    filter(:(PetalLength > 1.5), :(Species == "setosa"))
=#

function resolve_filter(ex, piped_to)
    args = exfargs(ex)
    arg1 = args[1]
    if !piped_to
        with_first(args, arg1, :filter, Expr)
    else # if piped to, assumed all args are conditions
        conds = QueryArg{Expr}[ QueryArg(cond) for cond in args ]
        return quote
            filter($conds)
        end
    end
end

function resolve_select(ex, piped_to)
    args = exfargs(ex)
    arg1 = args[1]
    if !piped_to
        with_first(args, arg1, :select, Symbol)
    else # if piped to, assume all args are columns
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
    _input = resolve(input)
    return Expr(:call, method, _input, args)
end

resolve(x) = resolve(x, false)
resolve(x, piped_to) = x

function resolve(ex::Expr, piped_to)
    if ex.head == :call
        f = exf(ex)
        args = exfargs(ex)
        if f == :filter
            return resolve_filter(ex, piped_to)
        elseif f == :select
            return resolve_select(ex, piped_to)
        elseif exf(ex) == :|>
            return Expr(:call, :|>, resolve(args[1], false), resolve(args[2], true))
        end
    else
        return ex
    end
end
