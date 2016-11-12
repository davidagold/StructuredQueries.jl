# """
#     Query
#
# Wrap a `QueryNode` graph that represents the structure of a query passed to the
# `@query` macro.
# """
# type Query
#     graph::QueryNode
# end

immutable Cursor
    graph::Node
end
