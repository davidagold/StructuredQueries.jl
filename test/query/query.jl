module TestQuery

using StructuredQueries
using Base.Test

io = IOBuffer()
disp = TextDisplay(IOBuffer())

immutable MyData end
src = MyData()
_src = MyData()

n = 10
A = rand(n)
B = collect(1:n)
D = rand(["a", "b"], n)

# select

c1 = @with src select(A)
c2 = @with src begin
    select(A)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src select(C = A * B)
c2 = @with src begin
    select(C = A * B)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src select(A, C = A * B)
c2 = @with src begin
    select(A, C = A * B)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

# filter

c1 = @with src filter(A > .5)
c2 = @with src begin
    filter(A > .5)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c2)

# orderby

c1 = @with src orderby(A)
c2 = @with src begin
    orderby(A)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src orderby(5 * B)
c2 = @with src begin
    orderby(5 * B)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src orderby(A, 5 * B)
c2 = @with src begin
    orderby(A, 5 * B)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

# groupby

c1 = @with src groupby(D)
c2 = @with src begin
    groupby(D)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src groupby(A > .5)
c2 = @with src begin
    groupby(A > .5)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

c1 = @with src groupby(D, A > .5)
c2 = @with src begin
    groupby(D, A > .5)
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)

# summarize

c1 = @with src summarize(avg_A = mean(A))
c2 = @with src begin
    summarize(avg_A = mean(A))
end
@test isequal(c1, c2)
show(io, c1)
display(disp, c1)


end
