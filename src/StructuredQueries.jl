module StructuredQueries

using Compat

export  Query,
        @query,
        @collect,
        source,
        graph

include("utilities.jl")

##############################################################################
##
## query
##
##############################################################################

# QueryHelper API
include("query/helper/type_definitions.jl")
include("query/helper/primitives.jl")

# QueryNode API
include("query/node/type_definitions.jl")
include("query/node/primitives.jl")
include("query/node/show.jl")

# Query API
include("query/type_definitions.jl")
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
include("query/graph/kernel/assignments.jl")
include("query/graph/kernel/symbol_analysis.jl")
include("query/graph/kernel/kernel.jl")

##############################################################################
##
## collect
##
##############################################################################

# collect API
include("collect/utilities.jl")
include("collect/collect.jl")
include("collect/lift.jl")

end # module StructuredQueries
