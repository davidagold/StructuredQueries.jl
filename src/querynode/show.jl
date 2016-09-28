pad(io, n)::Void = print(io, " "^n)

function Base.show(io::IO, q::QueryNode, leftmargin=0)::Void
    println(name(typeof(q)))
    pad(io, leftmargin+2); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println("$i)  ", arg)
    end
    pad(io, leftmargin+2); println("inputs:")
    pad(io, leftmargin+6); print(io, "1)  ")
    show(io, q.input, leftmargin+10)
    return
end

function Base.show(io::IO, q::JoinNode, leftmargin=0)::Void
    println(name(typeof(q)))
    pad(io, leftmargin+2); println("arguments:")
    for (i, arg) in enumerate(q.args)
        pad(io, leftmargin+6); println("$i)  ", arg)
    end
    pad(io, leftmargin+2); println("inputs:")
    pad(io, leftmargin+6); print(io, "1)  ")
    show(io, q.input1, leftmargin+10)
    pad(io, leftmargin+6); print(io, "2)  ")
    show(io, q.input2, leftmargin+10)
    return
end

function Base.show(io::IO, d::DataNode, leftmargin)::Void
    # println("Data source: ", d.input)
    println(name(typeof(d)))
    pad(io, leftmargin+2); print("source:  ")
    if isdefined(d, :input)
        println("source of type ", name(typeof(d.input)))
    else
        println("unset source")
    end
    return
end

name(x::Symbol) = x
name(x::DataType) = name(x.name)
name(x::TypeName) = x.name
