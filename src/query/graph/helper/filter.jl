# # NOTE: FilterHelper has its own definition because args are processed together
# function process_args(::Val{:filter}, exs, index)::Tuple{Set{Symbol}, Expr}
#     helpers_ex = Expr(:ref, Helper{:filter})
#     predicate = aggregate(exs)
#
#     ds = Dict{Symbol, Set{Symbol}}(
#         token => Set{Symbol}() for token in keys(index)
#     )
#
#     srcs = Set{Symbol}()
#     f_ex, arg_fields = build_f_ex!(ds, srcs, predicate, index)
#     # println(1)
#
#     push!(
#         helpers_ex.args,
#         Expr(:call, Helper{:filter}, Expr(:tuple, f_ex, arg_fields))
#     )
#     return srcs, helpers_ex
# end
#
# aggregate(args) = foldl((x,y)->:( $x & $y ), args)
