module jplyr
using Reexport
include("AbstractTables/AbstractTables.jl")
@reexport using .AbstractTables

export @query,
    @filter,
    @select,
    @groupby,
    @mutate,
    @summarize
    # following are exported only for test purposes

# Graph interface
include("querynode.jl")
include("query.jl")

# AbstractTable utils
include("abstracttable/assignment_expr_ops.jl")
include("abstracttable/sym_analysis.jl")

# include("abstracttable/01_expr.jl")
# include("abstracttable/02_fill.jl")
# include("abstracttable/04_make_funcs.jl")

# One-off interface
include("select.jl")
include("filter.jl")
include("groupby.jl")
include("mutate.jl")
include("summarize.jl")

# Execution
include("collect.jl")
include("generic.jl")
include("utils.jl")

end # module
