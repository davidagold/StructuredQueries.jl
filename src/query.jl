macro query(qry)
    src, g = gen_graph(qry)
    # generate expression to set helpers.
    # TODO: leverage graph information to optimize helpers/execution
    set_helpers!_ex = build_helper_exs(g)
    return quote
        $set_helpers!_ex
        set_src!($g, $(esc(src[1])))
        $g
    end
end

exf(ex) = ex.args[1]
exfargs(ex) = ex.args[2:end]

const manip_types = Dict{Symbol, DataType}(
    :filter => FilterNode,
    :select => SelectNode,
    :groupby => GroupbyNode,
    :orderby => OrderbyNode,
    :mutate => MutateNode,
    :summarize => SummarizeNode,
    :summarise => SummarizeNode
)

function gen_graph(x)
    src = Vector{Symbol}()
    return src, gen_graph!(x, false, src)
end

function gen_graph!(x::Symbol, piped_to, src)
    isempty(src) && push!(src, x)
    return DataNode()
end

function gen_graph!(ex::Expr, piped_to, src)
    if ex.head == :call
        f = exf(ex)
        args = exfargs(ex)
        if haskey(manip_types, f)
            gen_node!(ex, piped_to, manip_types[f], src)
        elseif f == :|>
            return (gen_graph!(args[1], false, src) |>
                    gen_graph!(args[2], true, src))
        end
    end
end

function gen_node!(ex, piped_to, T, src)
    args = exfargs(ex)
    input = args[1]
    if !piped_to
        T(gen_graph!(input, false, src), args[2:end])
    else # if piped to, assume all args are conditions
        return x -> T(x, args)
    end
end

function build_helper_exs(g)
    def_kernels_ex = Expr(:block)
    set_helpers!_ex = Expr(:block)
    return build_helper_exs!(g, set_helpers!_ex)
end

build_helper_exs!(g::DataNode, set_helpers!_ex) = set_helpers!_ex
build_helper_exs!(g::QueryNode, set_helpers!_ex) =
    build_helper_exs!(g.input, set_helpers!_ex)

function build_helper_exs!{T<:QueryNode}(g::T, set_helpers!_ex)
    helper_ex = _build_helper_ex(T, g.args)
    push!(set_helpers!_ex.args,
          :( set_helper!($g, $helper_ex) )
    )
    return build_helper_exs!(g.input, set_helpers!_ex)
end
