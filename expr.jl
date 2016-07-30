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
    mapping = Dict{Symbol, Int}()
    reverse_mapping = Array(Symbol, length(s))
    for (i, sym) in enumerate(s)
        mapping[sym] = i
        reverse_mapping[i] = sym
    end
    return mapping, reverse_mapping
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
