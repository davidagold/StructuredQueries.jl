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
            empty

    include("table/table.jl")
    include("table/grouped_table/grouped_table.jl")
    include("table/grouped_table/show.jl")
end
