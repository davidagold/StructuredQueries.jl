pad(io, n) = print(io, " "^n)

function Base.show(io::IO, q::QueryNode, leftmargin=0, depth=0)
    d = depth * 4
    println(typeof(q))
    pad(io, leftmargin+2+d); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6+d); println("$i)  ", arg)
    end
    pad(io, leftmargin+2+d); println("inputs:")
    pad(io, leftmargin+6+d); print(io, "1)  ")
    show(io, q.input, leftmargin+6+d, depth+1)
end

function Base.show(io::IO, q::JoinNode, leftmargin=0, depth=0)
    d = depth * 4
    println(typeof(q))
    pad(io, leftmargin+2+d); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println("$i)  ", arg)
    end
    pad(io, leftmargin+2+d); println("inputs:")
    pad(io, leftmargin+6+d); print(io, "1)  ")
    show(io, q.input1, leftmargin+6, depth+1)
    pad(io, leftmargin+6+d); print(io, "2)  ")
    show(io, q.input2, leftmargin+6, depth+1)
end

function Base.show(io::IO, d::DataNode, leftmargin, depth)
    println("Data source: ", d.input)
end
