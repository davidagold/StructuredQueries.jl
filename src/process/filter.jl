function process_arg!(node::FilterNode, filter_pred)
    arg_parameters = Set{Symbol}()
    kernel_ex, arg_fields = build_kernel_ex!(filter_pred, arg_parameters)
    for p in arg_parameters
        push!(node.parameters, p)
    end
    return quote
        FilterHelper($kernel_ex, $arg_fields)
    end
end

function _process_node!(g::FilterNode)
    # TODO: check_node(g)
    helpers_ex = Expr(:ref, :FilterHelper)
    filter_pred = aggregate(g.args)
    helper_ex = process_arg!(g, filter_pred)
    push!(helpers_ex.args, helper_ex)
    return helpers_ex
end

aggregate(args) = foldl((x,y)->:($x & $y), args)
