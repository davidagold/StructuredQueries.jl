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
include("abstracttable/01_expr.jl")
include("abstracttable/02_fill.jl")
include("abstracttable/03_apply.jl")
include("abstracttable/04_make_funcs.jl")

# One-off interface
include("select.jl")
include("filter.jl")
include("groupby.jl")
include("mutate.jl")
include("summarize.jl")
include("collect.jl")

end # module
