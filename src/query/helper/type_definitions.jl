"""
    abstract QueryHelper

Leaf subtypes `T <: QueryHelper` contain data extracted from query arguments
and stored in fields of `T` as resources for collection machineries.
"""
abstract QueryHelper

abstract JoinHelper <: QueryHelper

immutable SelectHelper{F} <: QueryHelper
    result_field::Symbol
    f::F
    argument_fields::Vector{Symbol}
end

immutable FilterHelper{F} <: QueryHelper
    f::F
    argument_fields::Vector{Symbol}
end

immutable OrderbyHelper{F} <: QueryHelper
    f::F
    argument_fields::Vector{Symbol}
end

immutable GroupbyHelper{F} <: QueryHelper
    is_predicate::Bool
    f::F
    argument_fields::Vector{Symbol}
end

immutable SummarizeHelper{F, G} <: QueryHelper
    result_field::Symbol
    f::F
    g::G
    argument_fields::Vector{Symbol}
end

immutable LeftJoinHelper{F, G} <: JoinHelper
    f::F
    g::G
    argument_fields1::Vector{Symbol}
    argument_fields2::Vector{Symbol}
end

immutable OuterJoinHelper{F, G} <: JoinHelper
    f::F
    g::G
    argument_fields1::Vector{Symbol}
    argument_fields2::Vector{Symbol}
end

immutable InnerJoinHelper{F, G} <: JoinHelper
    f::F
    g::G
    argument_fields1::Vector{Symbol}
    argument_fields2::Vector{Symbol}
end

immutable CrossJoinHelper{F, G} <: JoinHelper
    f::F
    g::G
    argument_fields1::Vector{Symbol}
    argument_fields2::Vector{Symbol}
end
