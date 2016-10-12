# NOTE: FilterHelper has its own definition because args are processed together,
#       not individually
function gen_helpers_ex(::Type{FilterHelper}, exs)::Expr
    helpers_ex = Expr(:ref, FilterHelper)
    arg_parameters = Set{Symbol}()
    predicate = aggregate(exs)
    f_ex, arg_fields = build_kernel_ex!(predicate, arg_parameters)
    push!(helpers_ex.args, Expr(:call, FilterHelper, f_ex, arg_fields))
    return helpers_ex
end

aggregate(args) = foldl((x,y)->:( $x & $y ), args)
