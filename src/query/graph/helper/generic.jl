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
    srcs_used = Set{Symbol}()
    for ex in exs
        process_arg!(srcs_used, helpers_ex, Val{U}(), ex, index)
    end

    return srcs_used, helpers_ex
end

function process_arg! end
