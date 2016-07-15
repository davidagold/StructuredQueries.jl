macro filter(input::Symbol, ex::Expr...)
    local lex = QuoteNode(ex)
    quote
        _filter($(esc(input)), $lex)
    end
end

macro filter(ex::Expr...)
    local lex = QuoteNode(ex)
    quote
        _filter($lex)
    end
end

_filter(input::DataFrame, ex) = FilterNode(DataNode(input), collect(ex))
_filter(input::QueryNode, ex) = FilterNode(input, collect(ex))
_filter{N}(exs::Tuple{Vararg{Expr, N}}) = x -> _filter(x, exs)
_filter(exs) = x -> _filter(x, exs)

Base.filter(conds::Vector{QueryArg{Expr}}) = x -> filter(x, conds)
function Base.filter(input::DataFrame, conds::Vector{QueryArg{Expr}})
    return FilterNode(DataNode(input), collect(conds))
end
function Base.filter(input::QueryNode, conds::Vector{QueryArg{Expr}})
    return FilterNode(input, conds)
end
