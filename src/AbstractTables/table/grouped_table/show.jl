function Base.show(
    io::IO,
    g_tbl::GroupedTable,
    # splitchunks::Bool = true,
    rowlabel::Symbol = Symbol("Row"),
    displaysummary::Bool = true
)::Void
    groupings = g_tbl.groupings
    nargs = length(groupings)
    println(io, "GroupedTable")
    println(io, "Groupings by:")
    for grouping in groupings
        print(io, " "^4)
        @printf("%s \n", string(grouping))
    end
    println()
    return show(io, g_tbl.source, :Row, false)
end
