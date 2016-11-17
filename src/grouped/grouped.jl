immutable Grouped{T,I,L}
    src::T
    group_indices::I
    groupbys::Vector{Symbol}
    group_levels::L
    metadata::Dict{Symbol, Any}
end
