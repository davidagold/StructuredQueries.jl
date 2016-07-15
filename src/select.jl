macro select(input::Expr, cols::Symbol...)
    return quote
        x = $(esc(input))
        _select(x, $cols)
    end
end

macro select(syms...)
    if isdefined(syms[1])
        if length(syms) > 1
            _cols = syms[2:end]
        else
            _cols = []
        end
        return quote
            _select($(esc(syms[1])), $_cols)
        end
    else
        return quote
            _select($syms)
        end
    end
end

_select(input::QueryNode, cols::Vector{Symbol}) = SelectNode(input, cols)
_select(input::QueryNode, cols::Tuple{Symbol}) = SelectNode(input, collect(cols))
_select(input::DataFrame, cols) = SelectNode(DataNode(input), cols)
_select{N}(cols::Tuple{Vararg{Symbol, N}}) = x -> _select(x, collect(cols))

Base.select(cols::Vector{QueryArg{Symbol}}) = x -> select(x, cols)
Base.select(df::DataFrame, cols::Vector{QueryArg{Symbol}}) =
    SelectNode(DataNode(df), cols)
Base.select(input::QueryNode, cols::Vector{QueryArg{Symbol}}) =
    SelectNode(input, cols)
