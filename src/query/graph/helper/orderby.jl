function helper(::Type{OrderbyHelper}, ex)::Expr
    argument_parameters = Set{Symbol}()
    f_expression, argument_fields = kernel!(ex, argument_parameters)
    return Expr(:call, OrderbyHelper, f_expression, argument_fields)
end
