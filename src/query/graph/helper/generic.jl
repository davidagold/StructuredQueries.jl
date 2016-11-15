# NOTE: FilterHelper has its own implementation in filter.jl

"""
    helpers(H, args)::Expr

Return an `Expr` to produce a `Vector{H<:QueryHelper}`, for which each element
is derived from a query argument in `args`.
"""
function helpers(H, args)::Expr
    helpers_expression = Expr(:ref, H)
    for arg in args
        push!(helpers_expression.args, helper(H, arg))
    end
    return helpers_expression
end

"""
    helper(H, arg)::Expr

Return an `Expr` to produce an `H <: QueryHelper` object from the query argument
`arg`.
"""
function helper end
