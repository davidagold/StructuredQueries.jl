# NOTE: FilterHelper has its own implementation in filter.jl
function gen_helpers_ex(H, args)
    helpers_ex = Expr(:ref, H)
    for arg in args
        push!(helpers_ex.args, gen_helper_ex(H, arg))
    end
    return helpers_ex
end
