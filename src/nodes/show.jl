pad(io, n)::Void = print(io, " "^n)

# function Base.show(io::IO, q::QueryNode, leftmargin=0)::Void
#     println(io, name(typeof(q)))
#     pad(io, leftmargin+2); println(io, "arguments:")
#     for (i, arg) in enumerate(q.args)
#         pad(io, leftmargin+6); println(io, "$i)  ", arg)
#     end
#     pad(io, leftmargin+2); println(io, "inputs:")
#     pad(io, leftmargin+6); print(io, "1)  ")
#     show(io, q.input, leftmargin+10)
#     return
# end

function Base.show(io::IO, q::QueryNode, leftmargin=0)::Void
    println(io, name(typeof(q)))
    pad(io, leftmargin+2); println(io, "arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println(io, "$i)  ", arg)
    end
    pad(io, leftmargin+2); println(io, "inputs:")
    for (i, input) in enumerate(q.inputs)
        pad(io, leftmargin+6); print(io, "$i)  ")
        show(io, input, leftmargin+10)
    end
    return
end

function Base.show(io::IO, d::DataNode, leftmargin)::Void
    # println("Data source: ", d.input)
    println(io, name(typeof(d)))
    pad(io, leftmargin+2); print(io, "source:  ")
    if isdefined(d, :input)
        println(io, "source of type ", name(typeof(d.input)))
    else
        println(io, "unset source")
    end
    return
end
