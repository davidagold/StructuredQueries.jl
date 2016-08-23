"""
"""
abstract QueryHelper
# NOTE: Perhaps later we will decide the following typealias provides a nice
# conceptual finish
# typealias ArgFields Vector{Symbol}

"""
"""
immutable SelectHelper{F} <: QueryHelper
    res_field::Symbol
    f::F
    arg_fields::Vector{Symbol}
end

"""
"""
immutable FilterHelper{F} <: QueryHelper
    f::F
    arg_fields::Vector{Symbol}
end

"""
"""
immutable GroupbyHelper{F} <: QueryHelper
    is_predicate::Bool
    f::F
    arg_fields::Vector{Symbol}
end

"""
"""
immutable SummarizeHelper{F, G} <: QueryHelper
    res_field::Symbol
    f::F
    g::G
    arg_fields::Vector{Symbol}
end
