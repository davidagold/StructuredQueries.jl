function process_arg!(srcs_used, dos_ex, ::Type{Select}, ex, index, primary)::Void
    res_field, value_ex = result_column(ex)
    f_ex, ai = build_f_ex!(srcs_used, value_ex, index, primary)
    push!(dos_ex.args,
          Expr(:call, Select, res_field, f_ex, ai))
    return
end
