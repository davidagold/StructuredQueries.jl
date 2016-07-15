macro select(input::Expr, cols::Symbol...)
    _cols = [ QueryArg(col) for col in cols ]
    return quote
        x = $(esc(input))
        select(x, $_cols)
    end
end

macro select(syms...)
    if isdefined(syms[1])
        if length(syms) > 1
            _cols = QueryArg{Symbol}[ QueryArg(sym) for sym in syms[2:end] ]
        else
            _cols = QueryArg{Symbol}[]
        end
        return quote
            select($(esc(syms[1])), $_cols)
        end
    else
        _syms = [ QueryArg(sym) for sym in syms ]
        return quote
            select($_syms)
        end
    end
end

Base.select(cols::Vector{QueryArg{Symbol}}) = x -> select(x, cols)
Base.select(df::DataFrame, cols::Vector{QueryArg{Symbol}}) =
    SelectNode(DataNode(df), cols)
Base.select(input::QueryNode, cols::Vector{QueryArg{Symbol}}) =
    SelectNode(input, cols)
