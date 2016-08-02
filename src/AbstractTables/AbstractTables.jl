module AbstractTables
    using Compat
    using Reexport
    @reexport using NullableArrays

    export  AbstractTable,
            Table,
            index,
            fields,
            nrow,
            ncol,
            columns,
            eachcol,
            eachrow,
            empty,
            eltypes
            # for test purposes

    include("abstracttable.jl")
    include("table.jl")
    include("show.jl")
end
