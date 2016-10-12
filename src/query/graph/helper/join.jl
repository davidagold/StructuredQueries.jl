function gen_helper_ex{H<:JoinHelper}(::Type{H}, ex)::Expr
    arg_parameters = Set{Symbol}()
    lhs, rhs = ex.args[1], ex.args[2]
    f_ex, f_arg_fields = build_kernel_ex!(lhs, arg_parameters)
    g_ex, g_arg_fields = build_kernel_ex!(rhs, arg_parameters)
    return Expr(:call, H, f_ex, g_ex, f_arg_fields, g_arg_fields)
end
