const DEALIAS = Dict{Symbol, Symbol}(
    :join => :innerjoin,
)

# NOTE: FilterHelper has its own implementation in filter.jl
"""
"""
function process_args{V}(::Val{V}, exs, index)
    U = get(DEALIAS, V, V)
    helpers_ex = Expr(:ref, Helper{U})
    # Each source gets its own symbol set, which we use to build the
    # mappings/reverse mappings (see build_f_ex!)
    ds = Dict{Symbol, Set{Symbol}}()
    srcs = Set{Symbol}()
    for ex in exs
        process_arg!(ds, srcs, helpers_ex, Val{U}(), ex, index)
    end

    return srcs, helpers_ex
end

function process_arg! end




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
