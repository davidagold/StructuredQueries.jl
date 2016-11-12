immutable ArgsIndex
    index::Dict{Symbol, Int}
    args::Vector{Set{Symbol}}
end
ArgsIndex() = ArgsIndex(Dict{Symbol,Int}(), Vector{Set{Symbol}}())

Base.getindex(ai::ArgsIndex, t::Symbol) = ai.args[ai.index[t]]
function Base.setindex!(ai::ArgsIndex, s, t::Symbol)
    i = get!(ai.index, t, length(ai.index)+1)
    i == length(ai.index) ? push!(ai.args, s) : (ai.args[i] = s)
    return s
end
Base.get!(ai::ArgsIndex, t::Symbol) = haskey(ai.index, t) ? (ai[t]) : (ai[t] = Set{Symbol}())

"""
    abstract QueryHelper

Leaf subtypes `T <: QueryHelper` contain data extracted from query arguments
and stored in fields of `T` as resources for collection machineries.
"""
abstract Verb

immutable Select{F} <: Verb
    res_field::Symbol
    f::F
    ai::ArgsIndex
end
immutable Filter{F} <: Verb
    f::F
    ai::ArgsIndex
end
immutable OrderBy{F} <: Verb
    f::F
    ai::ArgsIndex
end
immutable GroupBy{F} <: Verb
    is_predicate::Bool
    f::F
    ai::ArgsIndex
end
immutable Summarize{F,G} <: Verb
    res_field::Symbol
    f::F
    g::G
    ai::ArgsIndex
end
immutable LeftJoin{F,G} <: Verb
    fs::Tuple{F,G}
    ais::Tuple{ArgsIndex,ArgsIndex}
end
immutable OuterJoin{F,G} <: Verb
    fs::Tuple{F,G}
    ais::Tuple{ArgsIndex,ArgsIndex}
end
immutable InnerJoin{F,G} <: Verb
    fs::Tuple{F,G}
    ais::Tuple{ArgsIndex,ArgsIndex}
end
immutable CrossJoin{F,G} <: Verb
    fs::Tuple{F,G}
    ais::Tuple{ArgsIndex,ArgsIndex}
end
