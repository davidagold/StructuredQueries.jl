module StructuredQueries

export  Query,
        @query,
        @collect

include("utils.jl")

##############################################################################
##
## query
##
##############################################################################

# QueryHelper API
include("query/helper/typedefs.jl")
include("query/helper/primitives.jl")

# QueryNode API
include("query/node/typedefs.jl")
include("query/node/primitives.jl")
include("query/node/show.jl")

# Query API
include("query/typedef.jl")
include("query/primitives.jl")
include("query/macros.jl")
include("query/show.jl")

# graph generation
include("query/graph/graph.jl")
## helper generation
include("query/graph/helper/generic.jl")
include("query/graph/helper/select.jl")
include("query/graph/helper/filter.jl")
include("query/graph/helper/orderby.jl")
include("query/graph/helper/groupby.jl")
include("query/graph/helper/summarize.jl")
include("query/graph/helper/join.jl")
## kernel generation
include("query/graph/kernel/assignment_expr_ops.jl")
include("query/graph/kernel/sym_analysis.jl")
include("query/graph/kernel/kernel.jl")

##############################################################################
##
## collect
##
##############################################################################

# collect API
include("collect/utils.jl")
include("collect/collect.jl")
include("collect/lift.jl")

end # module StructuredQueries
