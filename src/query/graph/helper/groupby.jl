function helper(::Type{GroupbyHelper}, ex)::Expr
    is_predicate = isa(ex, Expr) ? true : false
    argument_parameters = Set{Symbol}()
    f_expression, argument_fields = kernel!(ex, argument_parameters)
    return Expr(:call, GroupbyHelper, is_predicate, f_expression, argument_fields)
end
