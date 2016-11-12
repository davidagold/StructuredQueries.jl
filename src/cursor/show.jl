function Base.show(io::IO, c::Cursor)::Void
    @printf(io, "Cursor over a %s", typeof(source(c)))
end
