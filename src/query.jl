# TO DO: Figure out how to run complicated graphs
macro query(qry)
    src, g = gen_graph(qry)
    return quote
        $(esc(src[1])) |> x -> set_src!($g, x)
        $g
    end
end

exf(ex) = ex.args[1]
exfargs(ex) = ex.args[2:end]

const manip_types = Dict{Symbol, DataType}(:filter => FilterNode,
                                           :select => SelectNode,
                                           :groupby => GroupbyNode)

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
