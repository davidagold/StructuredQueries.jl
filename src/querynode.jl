abstract QueryNode

immutable DataNode <: QueryNode
    input::Symbol
end

immutable FilterNode <: QueryNode
    input::QueryNode
    conds::Vector{Expr}
end

FilterNode(input::Symbol, conds) = FilterNode(DataNode(input), conds)

immutable SelectNode <: QueryNode
    input::QueryNode
    fields::Vector{Symbol}
end

SelectNode(input::Symbol, cols) = SelectNode(DataNode(input), cols)
