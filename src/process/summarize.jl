function process_arg!(q::SummarizeNode, arg)::Expr
    res_field = QuoteNode(get_res_field(arg))
    # Extract the first layer, which we assume is the summarization function
    rhs_expr = arg.args[2]
    # TODO: check whether or not `g_name` is a query parameter
    g_name = rhs_expr.args[1]
    value_expr = rhs_expr.args[2]
    arg_parameters = Set{Symbol}()
    f_expr, arg_fields = build_kernel_ex!(value_expr, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!(
            $(q.helpers),
            SummarizeHelper($res_field, $f_expr, $(esc(g_name)), $arg_fields)
        )
    end
end
#
# function _process_node!(q::SummarizeNode)::Expr
#     check_node(q)
#     helpers_ex = Expr(:ref, :SummarizeHelper)
#     for arg in q.args
#         helper_ex = process_arg!(q, arg)
#         push!(helpers_ex.args, helper_ex)
#     end
#     return helpers_ex
# end

function check_node(g::SummarizeNode)
    for e in g.args
        @assert isa(e, Expr)
        @assert e.head == :kw
        @assert e.args[2].head == :call
    end
    return
end
