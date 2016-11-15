function helper(::Type{SummarizeHelper}, ex)::Expr
    result_field = QuoteNode(get_result_field(ex))
    # Extract the first layer, which we assume is the summarization function
    rhs_expr = ex.args[2]
    # TODO: check whether or not `g_name` is a query parameter
    g_name = rhs_expr.args[1]
    value_expression = rhs_expr.args[2]
    argument_parameters = Set{Symbol}()
    f_expression, argument_fields = kernel!(value_expression, argument_parameters)
    return Expr(
        :call, SummarizeHelper, result_field, f_expression, esc(g_name), argument_fields
    )
end
