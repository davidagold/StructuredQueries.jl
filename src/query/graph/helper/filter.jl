# NOTE: FilterHelper has its own definition because args are processed together,
#       not individually
function helpers(::Type{FilterHelper}, exs)::Expr
    helpers_expression = Expr(:ref, FilterHelper)
    argument_parameters = Set{Symbol}()
    predicate = aggregate(exs)
    f_expression, argument_fields = kernel!(predicate, argument_parameters)
    push!(helpers_expression.args, Expr(:call, FilterHelper, f_expression, argument_fields))
    return helpers_expression
end

aggregate(args) = foldl((x,y)->:( $x & $y ), args)
