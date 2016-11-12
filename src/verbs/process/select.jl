function process_arg!(srcs_used, helpers_ex, ::Type{Select}, ex, index)::Void
    res_field, value_ex = result_column(ex)
    f_ex, ai = build_f_ex!(srcs_used, value_ex, index)
    push!(helpers_ex.args,
          Expr(:call, Select, res_field, f_ex, ai))
    return
end
