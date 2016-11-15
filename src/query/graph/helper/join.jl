function helper{H<:JoinHelper}(::Type{H}, ex)::Expr
    argument_parameters = Set{Symbol}()
    lhs, rhs = ex.args[1], ex.args[2]
    f_expression, f_argument_fields = kernel!(lhs, argument_parameters)
    g_expression, g_argument_fields = kernel!(rhs, argument_parameters)
    return Expr(:call, H, f_expression, g_expression, f_argument_fields, g_argument_fields)
end
