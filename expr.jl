# NOTE: All functions here assume that they're given a keyword argument
# expression as found in the second argument of @foo(df, a = b + c).

get_column_name(e::Expr) = e.args[1]

get_core_expr(e::Expr) = e.args[2]

function find_symbols!(s::Set{Symbol}, e::Expr)
    @assert e.head == :call
    # Skip name of function being called, then descend through arguments.
    if length(e.args) > 1
        for i in 2:length(e.args)
            find_symbols!(s, e.args[i])
        end
    end
    return
end

function find_symbols!(s::Set{Symbol}, e::Symbol)
    push!(s, e)
    return
end

function find_symbols!(s::Set{Symbol}, e::Any)
    return
end

function find_symbols(e)
    s = Set{Symbol}()
    find_symbols!(s, e)
    return s
end

function map_symbols(s::Set{Symbol})
    d = Dict{Symbol, Int}()
    for (i, sym) in enumerate(s)
        d[sym] = i
    end
    return d
end

# Replace symbols with tuple indexing expressions.
function replace_symbols!(e::Expr, mapping::Dict, tpl_name::Symbol)
    @assert e.head == :call
    # Skip name of function being called, then descend through arguments.
    if length(e.args) > 1
        for i in 2:length(e.args)
            if isa(e.args[i], Symbol)
                e.args[i] = Expr(:ref, tpl_name, mapping[e.args[i]])
            else
                replace_symbols!(e.args[i], mapping, tpl_name)
            end
        end
    end
    return
end

function replace_symbols!(e::Any, mapping::Dict, tpl_name::Symbol)
    return
end

function replace_symbols(e::Expr, mapping::Dict, tpl_name::Symbol)
    new_e = copy(e)
    replace_symbols!(new_e, mapping, tpl_name)
    return new_e
end

function build_anon_func(e::Expr)
    tpl_name = gensym()
    s = find_symbols(e)
    mapping = map_symbols(s)
    new_e = replace_symbols(e, mapping, tpl_name)
    return Expr(:->, tpl_name, Expr(:block, Expr(:line, 1), new_e))
end

tmp_e = build_anon_func(get_core_expr(e))

macro foo(x, e)
    col_name = get_column_name(e)
    core_expr = get_core_expr(e)
    anon_func_expr = build_anon_func(core_expr)
    res = Expr(:call, :map, anon_func_expr, esc(x))
    return res
end

# e = :(a = b + c)
# core_e = get_core_expr(e)
# find_symbols!(s, core_e)
# build_anon_func(core_e)

d = Dict(:a => randn(100), :b => randn(100), :c => randn(100))
@run_func(d, d = a + b * c)
-> apply_tuple_func(d, mappings, tpl -> tpl[1] + tpl[2] * tpl[3])

x = Array(Tuple{Float64, Float64}, 1_000_000)
for i in 1:length(x)
    x[i] = randn(Float64), randn(Float64)
end
@foo(x, a = b + c)
macroexpand(quote @foo(x, a = b + c) end)
