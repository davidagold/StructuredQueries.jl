function result_column(e::Symbol)::Tuple{QuoteNode, Any}
    return QuoteNode(e), e
end

function result_column(e::Expr)::Tuple{QuoteNode, Any}
    if !(e.head == :(=) || e.head == :kw)
        error(@sprintf("Unable to extract result column from expression: %s", e))
    end

    res_field = e.args[1]
    if !isa(res_field, Symbol)
        error(@sprintf("Target column name is not a symbol: %s", s))
    end

    value_expr = e.args[2]

    return QuoteNode(res_field), value_expr
end


"""
Extract the assigned column's name from an assignment-like expression.

Arguments:

* e::Expr: An assignment-like expression, which is either a top-level
    assignment expression, which might look like `col3 = f(col1) + g(col2)`; or
    a function/macro's keyword argument expression, which might look like
    `foo(col3 = f(col1) + g(col2))`.

Returns:

* s::Symbol: A symbol specifying the column name that will be assigned to.
"""
function get_res_field(e::Expr)::Symbol
    if !(e.head == :(=) || e.head == :kw)
        error(@sprintf("Unable to extract column name from expression: %s", e))
    end

    s = e.args[1]
    if !isa(s, Symbol)
        error(@sprintf("Target column name is not a symbol: %s", s))
    end

    return s
end

"""
Extract the value-defining sub-expression from an assignment-like expression.

Arguments:

* e_in::Expr: An assignment-like expression, which is either a top-level
    expression like `col3 = f(col1) + g(col2)` or a function/macro's keyword
    argument like `foo(col3 = f(col1) + g(col2))`.

Returns:

* e_out::Any: A value-defining expression that will be used to compute the
    value assigned to the column implied by. May be a literal, a raw symbol or
    a full `Expr` object.
"""
function get_value_expr(e_in::Expr)::Any
    if !(e_in.head == :(=) || e_in.head == :kw)
        error(@sprintf("Unable to extract column name from %s", e_in))
    end

    value_expr = e_in.args[2]

    return value_expr
end
