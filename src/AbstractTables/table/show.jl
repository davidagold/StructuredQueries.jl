function show_tbl(io, tbl::Table, rowlabel, displaysummary, limit, offset)
    if ncol(tbl) > 0
        displaysummary && println(io, summary(tbl))
        show_tbl_groupby_predicates(io, tbl)
        maxwidths = getmaxwidths(tbl, rowlabel, limit, offset)
        rightmost = rightbound(io, maxwidths)
        show_tbl_header(io, tbl, maxwidths, rightmost, rowlabel)
        show_tbl_rows(io, tbl, maxwidths, rightmost, rowlabel, limit, offset)
    else
        @printf(io, "An empty %s", typeof(tbl))
    end
    return
end

function show_tbl_groupby_predicates(io, tbl)
    if haskey(tbl.metadata, :groupby_predicates)
        groupby_predicates = tbl.metadata[:groupby_predicates]
        println(io, "With the following grouping predicate aliases:")
        for field in collect(keys(groupby_predicates))
            print(io, " "^4)
            println(io, field, " => ", groupby_predicates[field])
            println(io)
        end
    end
    return
end
