module jplyr
using Reexport
include("AbstractTables/AbstractTables.jl")
@reexport using .AbstractTables

export  @query,
        @qcollect
    # following are exported only for test purposes

# Graph interface
include("querynode.jl")
include("query.jl")

# AbstractTable utils
include("abstracttable/assignment_expr_ops.jl")
include("abstracttable/sym_analysis.jl")

# Generic graph execution
include("collect.jl")

# Graph execution over AbstractTables
include("abstracttable/collect.jl")
include("abstracttable/generic.jl")
include("abstracttable/utils.jl")
include("abstracttable/select.jl")
include("abstracttable/filter.jl")
include("abstracttable/summarize.jl")

end # module jplyr
