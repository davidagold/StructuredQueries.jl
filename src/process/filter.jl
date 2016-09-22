function process_arg!(q::FilterNode, filter_pred)
    arg_parameters = Set{Symbol}()
    kernel_ex, arg_fields = build_kernel_ex!(filter_pred, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        push!($(q.helpers), FilterHelper($kernel_ex, $arg_fields))
    end
end
