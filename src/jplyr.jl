module jplyr
using Reexport
include("AbstractTables/AbstractTables.jl")
@reexport using .AbstractTables

export @query,
    @select,
    @filter,
    @groupby,
    @summarize
    # following are exported only for test purposes

# Graph interface
include("querynode.jl")
include("query.jl")

# AbstractTable utils
include("abstracttable/assignment_expr_ops.jl")
include("abstracttable/sym_analysis.jl")

# One-off interface
include("select.jl")
include("filter.jl")
include("groupby.jl")
include("summarize.jl")

# Execution
include("collect.jl")
include("generic.jl")
include("utils.jl")

end # module jplyr
