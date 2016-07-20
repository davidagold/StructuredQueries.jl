abstract QueryNode

immutable DataNode <: QueryNode
    input::Symbol
end

immutable FilterNode <: QueryNode
    input::QueryNode
    conds::Vector{Expr}
end

# FilterNode(input::Symbol, conds) = FilterNode(DataNode(input), conds)

immutable SelectNode <: QueryNode
    input::QueryNode
    fields::Vector{Symbol}
end

# SelectNode(input::Symbol, cols) = SelectNode(DataNode(input), cols)

immutable GroupbyNode <: QueryNode
    input::QueryNode
    fields::Vector{Symbol}
end

# GroupbyNode(input::Symbol, cols) = GroupbyNode(DataNode(input), cols)

for T in (:FilterNode, :SelectNode, :GroupbyNode)
    @eval $T(input::Symbol, xs) = $T(DataNode(input), xs)
end
