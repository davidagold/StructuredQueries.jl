# function process_arg!(node::SelectNode, e::Symbol)
#     # TODO: check for query parameters
#     # arg_parameters = Set{Symbol}()
#     res_field = QuoteNode(e)
#     arg_fields = [e]
#     return quote
#         SelectHelper($res_field, Base.identity, $arg_fields)
#     end
# end

function process_arg!(node::SelectNode, e)
    arg_parameters = Set{Symbol}()
    res_field, value_expr = result_column(e)
    f_expr, arg_fields = build_kernel_ex!(value_expr, arg_parameters)
    for p in arg_parameters
        push!(node.parameters, p)
    end
    return quote
        SelectHelper($res_field, $f_expr, $arg_fields)
    end
end

"""
"""
function _process_node!(q::SelectNode)
    helpers_ex = Expr(:ref, :SelectHelper)
    for arg in q.args
        # TODO: check_arg(arg)
        helper_ex = process_arg!(q, arg)
        push!(helpers_ex.args, helper_ex)
    end
    return helpers_ex
end
