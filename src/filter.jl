macro filter(input::Symbol, ex::Expr...)
    # local lex = QuoteNode(ex)
    conds = [ QueryArg(cond) for cond in ex ]
    return quote
        run(filter($(esc(input)), $conds))
    end
end

macro filter(ex::Expr...)
    conds = [ QueryArg(cond) for cond in ex ]
    return quote
        run(filter($conds))
    end
end

Base.filter(conds::Vector{QueryArg{Expr}}) = x -> filter(x, conds)
function Base.filter(input::DataFrame, conds::Vector{QueryArg{Expr}})
    return FilterNode(DataNode(input), collect(conds))
end
function Base.filter(input::QueryNode, conds::Vector{QueryArg{Expr}})
    return FilterNode(input, conds)
end
