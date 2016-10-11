function gen_helper_ex(::Type{GroupbyHelper}, ex)::Expr
    is_predicate = isa(ex, Expr) ? true : false
    arg_parameters = Set{Symbol}()
    f_ex, arg_fields = build_kernel_ex!(ex, arg_parameters)
    return Expr(:call, GroupbyHelper, is_predicate, f_ex, arg_fields)
end
