module StructuredQueries

using Compat

export  Cursor,
        Grouped,
        @with,
        source,
        graph

include("utils.jl")

# grouped
include("grouped/grouped.jl")
include("grouped/show.jl")

#verbs
include("verbs/verbs.jl")
include("verbs/primitives.jl")

include("verbs/expr/assignment_expr_ops.jl")
include("verbs/expr/scalar.jl")
include("verbs/expr/sym_analysis.jl")

include("verbs/process/generic.jl")
include("verbs/process/select.jl")
include("verbs/process/filter.jl")
include("verbs/process/orderby.jl")
include("verbs/process/groupby.jl")
include("verbs/process/join.jl")
include("verbs/process/summarize.jl")

#nodes
include("nodes/nodes.jl")
include("nodes/primitives.jl")
include("nodes/show.jl")

# cursors
include("cursor/cursor.jl")
include("cursor/primitives.jl")
include("cursor/show.jl")
include("cursor/macros.jl")
include("cursor/graph.jl")

# collect
include("collect/lift.jl")

end
