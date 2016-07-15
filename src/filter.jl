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
