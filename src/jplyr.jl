module jplyr

export  Query,
        @query,
        @collect
    # following are exported only for test purposes

# Graph interface
include("utils.jl")
include("expr/assignment_expr_ops.jl")
include("expr/sym_analysis.jl")
include("expr/kernel.jl")

include("queryhelper/typedefs.jl")
include("queryhelper/primitives.jl")

include("querynode/typedefs.jl")
include("querynode/primitives.jl")

# Queries
include("query/typedef.jl")
include("query/primitives.jl")
include("query/macros.jl")
include("query/graph.jl")

# macro argument processing
include("process/generic.jl")
include("process/select.jl")
include("process/filter.jl")
include("process/groupby.jl")
include("process/summarize.jl")

# Collect interface
include("collect.jl")

# Other
include("show.jl")

end # module jplyr
