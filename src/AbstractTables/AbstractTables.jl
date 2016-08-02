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

#= #### Notes
1. _names(index(df)) is required in abstractdataframe/show.jl for df an AbstractDataFrame
but is not implemented or required for AbstractIndex (nothing seems to be required for AbstractIndex)


=#
