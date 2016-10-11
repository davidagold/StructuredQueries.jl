function gen_helper_ex(::Type{SelectHelper}, ex)::Expr
    arg_parameters = Set{Symbol}()
    res_field, value_ex = result_column(ex)
    f_ex, arg_fields = build_kernel_ex!(value_ex, arg_parameters)
    return Expr(:call, SelectHelper, res_field, f_ex, arg_fields)
end
