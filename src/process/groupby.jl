"""
"""
function process_arg!(q::GroupbyNode, arg)
    is_predicate = isa(arg, Expr) ? true : false
    arg_parameters = Set{Symbol}()
    f_expr, arg_fields = build_kernel_ex!(arg, arg_parameters)
    for p in arg_parameters
        push!(q.parameters, p)
    end
    return quote
        GroupbyHelper($is_predicate, $f_expr, $arg_fields)
    end
end

"""
"""
function _process_node!(g::GroupbyNode)
    # TODO: check_node(g)
    helpers_ex = Expr(:ref, :GroupbyHelper)
    for arg in g.args
        # TODO: check_arg(arg)
        helper_ex = process_arg!(g, arg)
        push!(helpers_ex.args, helper_ex)
    end
    return helpers_ex
end
