# NOTE: FilterHelper has its own implementation in filter.jl
"""
"""
function process_args{V}(::Type{V}, exs, index, primary)::Tuple{Set{Symbol}, Expr}
    helpers_ex = Expr(:ref, V)
    # Each source gets its own symbol set, which we use to build the
    # mappings/reverse mappings (see build_f_ex!)
    srcs_used = Set{Symbol}()
    for ex in exs
        # println(1)
        process_arg!(srcs_used, helpers_ex, V, ex, index, primary)
    end

    return srcs_used, helpers_ex
end

function process_arg! end
