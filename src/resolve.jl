#=
- resolve scope of symbols in QueryNode data fields (e.g. in FilterNode
conditions)
- Is essentially Simon Byrne's scopefun! implementation from
https://gist.github.com/simonbyrne/30522225543b86f3f20e084220c2f485
=#

function resolve(g::FilterNode)
    fields, _conds = resolve(g.conds)
    cond = aggr(_conds)
    fdef = Expr(:->, Expr(:tuple, fields...), cond)
    return gensym("f"), fdef, fields
end

function resolve(conds)
    cols = Set{Symbol}()
    _conds = [ resolve!(cond, cols) for cond in conds ]
    return cols, _conds
end

resolve!(x, cols) = x
function resolve!(sym::Symbol, cols)
    push!(cols, sym)
    return sym
end

function resolve!(ex::Expr, cols)
    if ex.head == :$
        return ex.args[1]
    elseif ex.head == :call
        return Expr(:call, exf(ex), [ resolve!(arg, cols) for arg in exfargs(ex) ]...)
    elseif ex.head == :comparison
        return Expr(:comparison, resolve!(ex.args[1], cols), ex.args[2], resolve!(ex.args[3], cols))
    else
        return Expr([ resolve!(arg, cols) for arg in ex.args ]...)
    end
end

# aggregate filter conditions into a single expression
function aggr(_conds)
    len = length(_conds)
    if len == 1
        res = _conds[1]
    else
        res = :($(_conds[1]) & $(_conds[2]))
        if len > 2
            for i in 3:len
                res = :($res & $(_conds[i]))
            end
        end
    end
    return res
end
