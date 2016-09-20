function Base.show(io::IO, qry::Query{Symbol})
    @printf(io, "Query with dummy source %s", qry.source)
end

function Base.show{S}(io::IO, qry::Query{S})
    @printf(io, "Query with %s source", S)
end
