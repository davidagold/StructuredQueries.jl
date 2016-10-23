function process_arg!(ds, srcs, helpers_ex, ::Val{:groupby}, ex, index)::Void
    # We assume that any Expr with head :. is just an attribute specification
    # TODO: check that this assumption actually holds
    is_predicate = ifelse(ex.head == :., true, false)
    f_ex, arg_fields = build_f_ex!(ds, srcs, ex, index)
    push!(
        helpers_ex.args,
        Expr(
            :call, Helper{:groupby}, Expr(:tuple, is_predicate, f_ex, arg_fields)
        )
    )
    return
end


function gen_helper_ex(::Type{GroupbyHelper}, ex)::Expr
    is_predicate = isa(ex, Expr) ? true : false
    arg_parameters = Set{Symbol}()
    f_ex, arg_fields = build_kernel_ex!(ex, arg_parameters)
    return Expr(:call, GroupbyHelper, is_predicate, f_ex, arg_fields)
end
