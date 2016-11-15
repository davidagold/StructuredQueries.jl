function helper(::Type{SelectHelper}, ex)::Expr
    argument_parameters = Set{Symbol}()
    result_field, value_ex = result_column(ex)
    f_expression, argument_fields = kernel!(value_ex, argument_parameters)
    return Expr(:call, SelectHelper, result_field, f_expression, argument_fields)
end
