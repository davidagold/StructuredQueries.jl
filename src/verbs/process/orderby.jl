# function gen_helper_ex(::Type{OrderbyHelper}, ex)::Expr
#     arg_parameters = Set{Symbol}()
#     f_ex, arg_fields = build_kernel_ex!(ex, arg_parameters)
#     return Expr(:call, OrderbyHelper, f_ex, arg_fields)
# end
