function process_arg!(node::LeftJoinNode, e)
    arg_parameters = Set{Symbol}()

    lhs, rhs = e.args[1], e.args[2]

    f_expr, f_arg_fields = build_kernel_ex!(lhs, arg_parameters)
    g_expr, g_arg_fields = build_kernel_ex!(rhs, arg_parameters)

    for p in arg_parameters
        push!(node.parameters, p)
    end
    return quote
        LeftJoinHelper($f_expr, $g_expr, $f_arg_fields, $g_arg_fields)
    end
end

function _process_node!(q::LeftJoinNode)
    helpers_ex = Expr(:ref, :LeftJoinHelper)
    for arg in q.args
        # TODO: check_arg(arg)
        helper_ex = process_arg!(q, arg)
        push!(helpers_ex.args, helper_ex)
    end
    return helpers_ex
end
