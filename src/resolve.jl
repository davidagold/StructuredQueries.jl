#=
- resolve scope of symbols in QueryNode data fields (e.g. in FilterNode
conditions)
- Is essentially Simon Byrne's scopefun! implementation from
https://gist.github.com/simonbyrne/30522225543b86f3f20e084220c2f485
=#

function resolve_filter(_conds::Vector{Expr})
    fields, conds = resolve_conds(_conds)
    cond = aggr(conds)
    fdef = Expr(:->, Expr(:tuple, fields...), cond)
    return gensym("f"), fdef, fields
end

function resolve_conds(_conds)
    fields = Set{Symbol}()
    conds = [ resolve!(_cond, fields) for _cond in _conds ]
    return fields, conds
end

resolve!(x, fields) = x
function resolve!(sym::Symbol, fields)
    push!(fields, sym)
    return sym
end

function resolve!(ex::Expr, fields)
    if ex.head == :$
        return ex.args[1]
    elseif ex.head == :call
        return Expr(:call, exf(ex), [ resolve!(arg, fields) for arg in exfargs(ex) ]...)
    elseif ex.head == :comparison
        return Expr(:comparison, resolve!(ex.args[1], fields), ex.args[2], resolve!(ex.args[3], fields))
    else
        return Expr([ resolve!(arg, fields) for arg in ex.args ]...)
    end
end

aggr(conds) = foldl((x,y)->:($x & $y), conds)
