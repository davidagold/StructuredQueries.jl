function process_arg!(srcs_used, dos_ex, ::Type{GroupBy}, ex, index, primary)::Void
    # We assume that any Expr with head :. is just an attribute specification
    # TODO: check that this assumption actually holds
    is_predicate = isa(ex, Symbol) ? false : ifelse(ex.head == :., false, true)
    f_ex, ai = build_f_ex!(srcs_used, ex, index, primary)
    push!(dos_ex.args,
          Expr(:call, GroupBy, is_predicate, f_ex, ai))
    return
end
