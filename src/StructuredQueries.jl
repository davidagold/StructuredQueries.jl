module StructuredQueries

export  Query,
        @query,
        @collect

# Graph interface
include("utils.jl")
include("expr/assignment_expr_ops.jl")
include("expr/sym_analysis.jl")
include("expr/kernel.jl")

include("queryhelper/typedefs.jl")
include("queryhelper/primitives.jl")

include("querynode/typedefs.jl")
include("querynode/primitives.jl")
include("querynode/show.jl")

# query
include("query/typedef.jl")
include("query/primitives.jl")
include("query/macros.jl")
include("query/graph.jl")
include("query/show.jl")

# collect
include("collect/utils.jl")
include("collect/collect.jl")
include("collect/lift.jl")

# macro argument processing
include("process/utils.jl")
include("process/generic.jl")

include("process/select.jl")
include("process/filter.jl")
include("process/orderby.jl")
include("process/groupby.jl")
include("process/summarize.jl")

include("process/leftjoin.jl")
include("process/outerjoin.jl")
include("process/innerjoin.jl")
include("process/crossjoin.jl")

end # module StructuredQueries
