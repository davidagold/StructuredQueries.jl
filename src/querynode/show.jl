pad(io, n) = print(io, " "^n)

function Base.show(io::IO, q::QueryNode, leftmargin=0)
    println(typeof(q))
    pad(io, leftmargin+2); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println("$i)  ", arg)
    end
    pad(io, leftmargin+2); println("inputs:")
    pad(io, leftmargin+6); print(io, "1)  ")
    show(io, q.input, leftmargin+10)
end

function Base.show(io::IO, q::JoinNode, leftmargin=0)
    println(typeof(q))
    pad(io, leftmargin+2); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println("$i)  ", arg)
    end
    depth += 1
    pad(io, leftmargin+2); println("inputs:")
    pad(io, leftmargin+6); print(io, "1)  ")
    show(io, q.input1, leftmargin+10)
    pad(io, leftmargin+6); print(io, "2)  ")
    show(io, q.input2, leftmargin+10)
end

function Base.show(io::IO, d::DataNode, leftmargin)
    println("Data source: ", d.input)
end
