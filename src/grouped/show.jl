function Base.show(io::IO, g::Grouped)::Void
    groupbys = g.groupbys
    # nargs = length(groupbys)
    predicates = g.metadata[:predicates]
    @printf(io, "Grouped %s\n", name(typeof(g).parameters[1]))
    println(io, "Groupings by:")
    for groupby in groupbys
        print(io, " "^4)
        print_groupby(io, groupby, predicates)
    end
    println()
    print(io, "Source: "); show(io, g.src)
    return
end

function print_groupby(io, groupby, predicates)::Void
    if haskey(predicates, groupby)
        predicate = predicates[groupby]
        @printf(
            io, "%s (with alias :%s) \n", string(predicate), string(groupby)
        )
    else
        @printf(io, "%s \n", string(groupby))
    end
    return
end
