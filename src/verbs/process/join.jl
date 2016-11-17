function process_arg!(
  srcs_used, helpers_ex, ::Type{InnerJoin}, ex, index, primary)::Void
    # NOTE: Only equijoins are supported for now
    @assert ex.head == :call && ex.args[1] == :(==)
    lhs, rhs = ex.args[2], ex.args[3]
    f_ex1, ai1 = build_f_ex!(srcs_used, lhs, index, primary)
    f_ex2, ai2 = build_f_ex!(srcs_used, rhs, index, primary)
    push!(helpers_ex.args,
          Expr(:call, InnerJoin, Expr(:tuple,
                                      Expr(:tuple, f_ex1, f_ex2),
                                      Expr(:tuple, ai1, ai2))))
    return
end



# function gen_helper_ex{H<:JoinHelper}(::Type{H}, ex)::Expr
#     arg_parameters = Set{Symbol}()
#     ex.head != :call && throw(ArgumentError())
#     ex.args[1] != :(==) && throw(ArgumentError("Non-equijoins not supported."))
#     lhs, rhs = ex.args[2], ex.args[3]
#     f1_ex, arg_fields1 = build_kernel_ex!(lhs, arg_parameters)
#     f2_ex, arg_fields2 = build_kernel_ex!(rhs, arg_parameters)
#     return Expr(:call, H, f1_ex, f2_ex, arg_fields1, arg_fields2)
# end
