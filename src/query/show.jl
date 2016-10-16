function Base.show(io::IO, q::Query)::Void
    @printf(io, "Query against a source of type %s", typeof(source(q)))
end
