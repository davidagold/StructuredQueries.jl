# function process_arg!(q::FilterNode, filter_pred)
#     arg_parameters = Set{Symbol}()
#     kernel_ex, arg_fields = build_kernel_ex!(filter_pred, arg_parameters)
#     for p in arg_parameters
#         push!(q.parameters, p)
#     end
#     return quote
#         push!($(q.helpers), FilterHelper($kernel_ex, $arg_fields))
#     end
# end

# Has its own definition because args are processed together, not individually
function process_node!(q::FilterNode, push!_helpers_ex)::Void
    arg_parameters = Set{Symbol}()
    predicate = aggregate(q.args)
    f_ex, arg_fields = build_kernel_ex!(predicate, arg_parameters)
    # for p in arg_parameters
    #     push!(q.parameters, p)
    # end
    push!(
        push!_helpers_ex.args,
        quote
            push!(
                $(q.helpers),
                FilterHelper($f_ex, $arg_fields)
            )
        end
    )
    process_node!(q.input, push!_helpers_ex)
    return
end

aggregate(args) = foldl((x,y)->:( $x & $y ), args)
