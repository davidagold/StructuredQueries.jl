function process_arg!(q::SelectNode, e)::Expr
    arg_parameters = Set{Symbol}()
    res_field, value_expr = result_column(e)
    f_expr, arg_fields = build_kernel_ex!(value_expr, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!($(q.helpers), SelectHelper($res_field, $f_expr, $arg_fields))
    end
end
