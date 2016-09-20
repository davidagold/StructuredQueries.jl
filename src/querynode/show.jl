pad(io, n) = print(io, " "^n)

function Base.show(io::IO, g::QueryNode, leftmargin=0, depth=0)
    pad(io, min(leftmargin, 2))
    println(typeof(g), " with arguments:")
    for arg in g.args
        pad(io, leftmargin+4); println(arg)
    end
    println()
    pad(io, leftmargin); print("→→")
    show(io, g.input, leftmargin+4, depth+1)
end

function Base.show(io::IO, d::DataNode, leftmargin, depth)
    pad(io, 2); println("Data source: ", d.input)
end``
