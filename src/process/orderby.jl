function process_arg!(q::OrderbyNode, e)::Expr
    arg_parameters = Set{Symbol}()
    res_field, value_expr = result_column(e)
    f_expr, arg_fields = build_kernel_ex!(value_expr, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    println()
    return quote
        push!($(q.helpers), OrderbyHelper($f_expr, $arg_fields))
    end
end
