immutable Grouped{T, I}
    src::T
    group_indices::I
    groupbys::Vector{Symbol}
    group_levels
    metadata::Dict{Symbol, Any}
end
