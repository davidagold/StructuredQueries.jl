function result_column(e::Symbol)::Tuple{QuoteNode, Any}
    return QuoteNode(e), e
end

function result_column(e::Expr)::Tuple{QuoteNode, Expr}
    if e.head == :(=) || e.head == :kw
        # res_field = e.args[1]
        # if !isa(res_field, Symbol)
        #     error(@sprintf("Target column name is not a symbol: %s", s))
        # end
        # TODO: check arguments for validity
        lhs, value_ex = e.args[1], e.args[2]
        if isa(lhs, Expr) && lhs.head == :.
            token, _res_field = lhs.args[1], lhs.args[2]
            # _res_field is a :quote Expr. Also, wrap in QuoteNode so it doesn't
            # get eval'd
            res_field = QuoteNode(_res_field.args[1])
        elseif isa(lhs, Symbol)
            res_field = QuoteNode(lhs)
        end
    elseif e.head == :.
        token, _res_field = e.args[1], e.args[2]
        res_field = QuoteNode(_res_field.args[1])
        value_ex = e
    else
        error(@sprintf("Unable to extract result column from expression: %s", e))
    end
    return res_field, value_ex
end
