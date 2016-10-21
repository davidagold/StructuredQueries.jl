function gen_helper_ex{H<:JoinHelper}(::Type{H}, ex)::Expr
    arg_parameters = Set{Symbol}()
    ex.head != :call && throw(ArgumentError())
    ex.args[1] != :(==) && throw(ArgumentError("Non-equijoins not supported."))
    lhs, rhs = ex.args[2], ex.args[3]
    f1_ex, arg_fields1 = build_kernel_ex!(lhs, arg_parameters)
    f2_ex, arg_fields2 = build_kernel_ex!(rhs, arg_parameters)
    return Expr(:call, H, f1_ex, f2_ex, arg_fields1, arg_fields2)
end
