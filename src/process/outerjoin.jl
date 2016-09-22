function process_arg!(q::OuterJoinNode, e)
    arg_parameters = Set{Symbol}()

    lhs, rhs = e.args[1], e.args[2]

    f_expr, f_arg_fields = build_kernel_ex!(lhs, arg_parameters)
    g_expr, g_arg_fields = build_kernel_ex!(rhs, arg_parameters)

    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!(
            $(q.helpers),
            OuterJoinHelper($f_expr, $g_expr, $f_arg_fields, $g_arg_fields)
        )
    end
end
