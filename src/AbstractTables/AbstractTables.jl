module AbstractTables
    using Compat
    using Reexport
    @reexport using NullableArrays

    export  AbstractTable,
            nrow,
            ncol,
            eachcol,
            eachrow,
            eltypes
            # for test purposes

    include("abstracttable.jl")
    include("show.jl")

    export  Table,
            GroupedTable,
            index,
            fields,
            columns,
            empty,
            groupby_predicate

    include("table/table.jl")
    include("table/show.jl")
    include("grouped_table/grouped_table.jl")
    include("grouped_table/show.jl")
end
