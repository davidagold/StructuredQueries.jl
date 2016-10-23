"""
Recursively descends an expression's AST to find all of the symbols contained
in it. Inserts any unquoted symbols that are found into the set argument,
`s`. Note that this function is not designed to handle assignment-like
expressions: it is intended for application to value expressions only.

Arguments:

* s::Set{Symbol}: A set of symbols that will be mutated whenever any new
    symbols are found.
* e::Any: An expression-like object that will be descended through to find new
    symbols.

Returns:

* Void: This function is used exclusively to mutate the argument `s`.
"""
function find_symbols!(
    ds::Dict{Symbol, Set{Symbol}}, srcs::Set{Symbol}, e::Any,
    index::Dict{Symbol, Symbol},
)::Void
    if isa(e, Expr)
        if e.head == :call
            # ignore e.args[1], which cannot be a token-field ref
            for i in 2:length(e.args)
                find_symbols!(ds, srcs, e.args[i], index)
            end
        elseif e.head in (:(||), :(&&), :if)
            for i in 1:length(e.args)
                find_symbols!(ds, srcs, e.args[i], index)
            end
        elseif e.head == :.
            _token, _field = e.args[1], e.args[2]
            field = _field.args[1] # field comes wrapped in an Expr with head :quote
            if haskey(index, _token)
                s = Set{Symbol}() # Create a set s to hold the fields
                push!(s, field)
                ds[_token] = s # map token to s
                push!(srcs, index[_token]) # remember sources we need
            end
        else
            # NOTE: Do not descend when e is a QuoteNode.
        end
    end
    return
end

"""
Recursively descends an expression's AST to find all of the symbols contained
in it. Returns all found symbols in a `Set{Symbol}` object.

Arguments:

* e::Any: An expression-like object that will be descended through to find new
    symbols.

Returns:

* s::Set{Symbol}: A set containing all of the symbols found by descending
    through the expression-like object's AST.
"""
function find_symbols(e, index)::Dict{Symbol, Set{Symbol}}
    ds = Dict{Symbol, Set{Symbol}}()
    find_symbols!(ds, e)
    return ds
end

"""
Produce a mapping from symbols to numeric indices and a reverse mapping from
numeric indices to symbols.

Arguments:

* s::Set{Symbol}: A set of symbols that should be assigned numeric indices.

Returns:

* mapping::Dict{Symbol, Int}: A mapping from symbols to indices.
* reverse_mapping::Vector{Symbol}: A mapping from indices to symbols.
"""
function map_symbols(
        ds::Dict{Symbol, Set{Symbol}}
)::Tuple{Dict{Symbol, Dict{Symbol, Int}}, Dict{Symbol, Vector{Symbol}}}

    # @show ds

    smaps = Dict{Symbol, Dict{Symbol, Int}}()
    reverse_smaps = Dict{Symbol, Vector{Symbol}}()

    for token in collect(keys(ds))
        mapping = Dict{Symbol, Int}()
        s = ds[token]
        reverse_mapping = Array(Symbol, length(s))
        for (i, sym) in enumerate(s)
            mapping[sym] = i
            reverse_mapping[i] = sym
        end
        smaps[token] = mapping
        reverse_smaps[token] = reverse_mapping
    end
    return smaps, reverse_smaps
end


"""
Traverse an AST-like object and replace a fixed set of symbols with
tuple-indexing expressions.

Arguments:

* e::Any: An AST-like object.
* mapping:Dict{Symbol, Int}: A mapping from symbols to numeric indices.
* tuple_name::Symbol: The name of the tuple that will be indexed into.

Returns:

* new_e::Any: A new AST-like object with all symbols replaced with
    tuple-indexing operations.
"""
function replace_symbols(
    e::Any,
    smaps::Dict{Symbol, Dict{Symbol, Int}}
)::Any
    # @show smaps
    if isa(e, Expr)
        # To ensure purity, we copy any Expr objects rather than mutate them.
        new_e = copy(e)
        if e.head == :call
            # Do two things:
            #   1)  Escape function `f` being called so its not rooted to the
            #       module StructuredQueries
            #   2)  replace `f(xs...)` with `lift(f, xs...)`
            args_copy = copy(e.args)
            lifted_e = Expr(:call)
            push!(lifted_e.args, Expr(:., :StructuredQueries, QuoteNode(:lift)))
            push!(lifted_e.args, esc(args_copy[1]))
            for i in 2:length(args_copy)
                push!(
                    lifted_e.args,
                    replace_symbols(args_copy[i], smaps)
                )
            end
            return lifted_e
        elseif new_e.head == :quote
            # Just escape the expression
            return esc(new_e)
        elseif new_e.head == :$
            return esc(new_e.args[1])
        elseif new_e.head in (:(||), :(&&), :if)
            for i in 1:length(new_e.args)
                new_e.args[i] = replace_symbols(
                    new_e.args[i],
                    mapping
                )
            end
        elseif e.head == :.
            token, _field = e.args[1], e.args[2]
            field = _field.args[1] # field comes wrapped in Expr with head :quote
            if haskey(smaps, token)
                return Expr(:ref, token, smaps[token][field])
            else
                return e
            end
        else
            # TODO: Handle other kinds of Expr heads.
            error(
                @sprintf("Unknown Expr head type %s in %s", new_e.head, new_e)
            )
        end
        return new_e
    # elseif isa(e, Symbol)
    #     # Replace unquoted symbols with tuple indexing expressions.
    #     return Expr(:ref, tuple_name, mapping[e])
    # elseif isa(e, QuoteNode)
    #     # Replace quoted symbols with raw symbols.
    #     return e.value
    else
        # Hopefully we have a literal here since we stop going down the AST
        # when we hit this branch.
        return e
    end
    return
end
