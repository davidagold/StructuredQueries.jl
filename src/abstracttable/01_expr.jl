"""
Extract the requested column name from a column-defining expression.

Arguments:

* e::Expr: An assignment-like expression (e.g. `col3 = f(col1) + g(col2)`)

Returns:

* s::Symbol: A symbol specifying the column name implied by the assignment.
"""
function _get_column_name(e::Expr)
    @assert e.head == :(=) || e.head == :kw
    @assert isa(e.args[1], Symbol)
    return e.args[1]
end

"""
Extract the sub-expression that will define the values of a new column given
a column-defining expression.

Arguments:

* e_in::Expr: An assignment-like expression (e.g. `col3 = f(col1) + g(col2)`)

Returns:

* e_out::Expr: An expression defining the value to be assigned to the column.
"""
function _get_core_expr(e::Expr)
    @assert e.head == :(=) || e.head == :kw
    return e.args[2]
end

"""
Recursively descends an expression's AST to find all of the symbols contained
in it. Inserts any symbols that are found into the set argument, `s`.
"""
function _find_symbols!(s::Set{Symbol}, e::Expr)
    @assert e.head == :call || e.head == :quote || e.head == :$
    # Skip name of function being called, then descend through arguments.
    if length(e.args) > 1
        for i in 2:length(e.args)
            _find_symbols!(s, e.args[i])
        end
    end
    return
end

"""
As part of the recursive descent into an AST, handle QuoteNode objects.
"""
function _find_symbols!(s::Set{Symbol}, e::QuoteNode)
    push!(s, e)
    return
end

"""
As part of the recursive descent into an AST, handle encountered symbols.
"""
function _find_symbols!(s::Set{Symbol}, e::Symbol)
    push!(s, e)
    return
end

"""
Ignore anything encountered during recursive descent that's neither an `Expr`
nor a `Symbol`.
"""
function _find_symbols!(s::Set{Symbol}, e::Any)
    return
end

"""
A pure variant of `find_symbols!`.
"""
function _find_symbols(e)
    s = Set{Symbol}()
    _find_symbols!(s, e)
    return s
end

"""
Produce a mapping between symbols and numeric indices. Also produce the reverse
mapping along the way.
"""
function _map_symbols(s::Set{Symbol})
    mapping = Dict{Symbol, Int}()
    reverse_mapping = Array(Symbol, length(s))
    for (i, sym) in enumerate(s)
        mapping[sym] = i
        reverse_mapping[i] = sym
    end
    return mapping, reverse_mapping
end

"""
Replace all known symbols with tuple indexing expressions.
"""
function _replace_symbols!(e::Expr, mapping::Dict, tpl_name::Symbol)
    @assert e.head == :call || e.head == :quote || e.head == :$
    # Escape "interpolated" symbols
    if e.head == :$
        e.head = :escape
        return
    end
    # Escape the functions being called so they're not rooted to the TBL
    # module.
    e.args[1] = esc(e.args[1])
    # Skip name of function being called, then descend through arguments.
    if length(e.args) > 1
        for i in 2:length(e.args)
            if isa(e.args[i], Symbol)
                e.args[i] = Expr(:ref, tpl_name, mapping[e.args[i]])
            elseif isa(e.args[i], QuoteNode)
                e.args[i] = e.args[i].value
            elseif isa(e.args[i], Expr)
                if e.args[i].head == :quote
                    e.args[i] = esc(e.args[i].args[1])
                else
                    _replace_symbols!(e.args[i], mapping, tpl_name)
                end
            else
                _replace_symbols!(e.args[i], mapping, tpl_name)
            end
        end
    end
    return
end

"""
Handle the special-case of a `Symbol`.
"""
function _replace_symbols!(e::Any, mapping::Dict, tpl_name::Symbol)
    return
end

"""
A pure variant of `replace_symbols!`.
"""
function _replace_symbols(e::Expr, mapping::Dict, tpl_name::Symbol)
    new_e = copy(e)
    _replace_symbols!(new_e, mapping, tpl_name)
    return new_e
end

"""
A pure variant of `replace_symbols!`.
"""
function _replace_symbols(e::Symbol, mapping::Dict, tpl_name::Symbol)
    return Expr(:ref, tpl_name, mapping[e])
end
