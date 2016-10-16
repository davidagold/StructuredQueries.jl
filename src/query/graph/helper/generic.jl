# NOTE: FilterHelper has its own implementation in filter.jl

"""
    gen_helpers_ex(H, args)::Expr

Return an `Expr` to produce a `Vector{H<:QueryHelper}`, for which each element
is derived from a query argument in `args`.
"""
function gen_helpers_ex(H, args)::Expr
    helpers_ex = Expr(:ref, H)
    for arg in args
        push!(helpers_ex.args, gen_helper_ex(H, arg))
    end
    return helpers_ex
end

"""
    gen_helper_ex(H, arg)::Expr

Return an `Expr` to produce an `H <: QueryHelper` object from the query argument
`arg`.
"""
function gen_helper_ex end
