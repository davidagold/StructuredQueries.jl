function process_arg!(q::OrderbyNode, e)::Expr
    arg_parameters = Set{Symbol}()
    f_expr, arg_fields = build_kernel_ex!(e, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!($(q.helpers), OrderbyHelper($f_expr, $arg_fields))
    end
end
