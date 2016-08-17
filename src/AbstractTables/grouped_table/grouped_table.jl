type GroupedTable{T}
    source::Table
    group_indices::T
    group_levels
    groupbys
    metadata
end

type GroupLevels
    levels::Vector{Vector}
end

Base.indices(group_levels::GroupLevels, j) = group_levels.levels[j]

function Base.isequal(g_tbl1::GroupedTable, g_tbl2::GroupedTable)
    isequal(g_tbl1.source, g_tbl2.source) || return false
    isequal(g_tbl1.group_indices, g_tbl2.group_indices) || return false
    isequal(g_tbl1.groupings, g_tbl2.groupings) || return false
    return true
end

function Base.hash(g_tbl::GroupedTable)
    h = hash(g_tbl.source) + 1
    h = hash(g_tbl.indices, h)
    h = has(g.groupings, h)
    return @compat UInt(h)
end
