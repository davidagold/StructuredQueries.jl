function process_arg!(srcs_used, dos_ex, ::Type{Summarize}, ex, index, primary)::Void
    res_field, value_ex = result_column(ex)
    g_name, scalar_ex = value_ex.args[1], value_ex.args[2]
    f_ex, ai = build_f_ex!(srcs_used, scalar_ex, index, primary)
    push!(dos_ex.args,
          Expr(:call, Summarize, res_field, f_ex, esc(g_name), ai))
    return
end
