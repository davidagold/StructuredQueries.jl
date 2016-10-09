function process_arg!(q::GroupbyNode, arg)
    is_predicate = isa(arg, Expr) ? true : false
    arg_parameters = Set{Symbol}()
    f_expr, arg_fields = build_kernel_ex!(arg, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!($(q.helpers), GroupbyHelper($is_predicate, $f_expr, $arg_fields))
    end
end
