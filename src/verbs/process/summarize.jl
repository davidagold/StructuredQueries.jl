# function gen_helper_ex(::Type{SummarizeHelper}, ex)::Expr
#     res_field = QuoteNode(get_res_field(ex))
#     # Extract the first layer, which we assume is the summarization function
#     rhs_expr = ex.args[2]
#     # TODO: check whether or not `g_name` is a query parameter
#     g_name = rhs_expr.args[1]
#     value_expr = rhs_expr.args[2]
#     arg_parameters = Set{Symbol}()
#     f_ex, arg_fields = build_kernel_ex!(value_expr, arg_parameters)
#     return Expr(
#         :call, SummarizeHelper, res_field, f_ex, esc(g_name), arg_fields
#     )
# end
