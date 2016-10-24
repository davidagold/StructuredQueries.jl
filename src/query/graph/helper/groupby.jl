function process_arg!(srcs_used, helpers_ex, ::Val{:groupby}, ex, index)::Void
    # We assume that any Expr with head :. is just an attribute specification
    # TODO: check that this assumption actually holds
    is_predicate = ifelse(ex.head == :., true, false)
    f_ex, arg_fields = build_f_ex!(srcs_used, ex, index)
    push!(
        helpers_ex.args,
        Expr(
            :call, Helper{:groupby}, Expr(:tuple, is_predicate, f_ex, arg_fields)
        )
    )
    return
end
