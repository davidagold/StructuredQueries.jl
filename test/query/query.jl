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

q_a = @query select(src, A)
q_b = @query src |> select(A)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query select(src, C = A * B)
q_b = @query src |> select(C = A * B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query select(src, A, C = A * B)
q_b = @query src |> select(A, C = A * B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# filter

q_a = @query filter(src, A > .5)
q_b = @query src |> filter(A > .5)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# orderby

q_a = @query orderby(src, A)
q_b = @query src|> orderby(A)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query orderby(src, 5 * B)
q_b = @query src |> orderby(5 * B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query orderby(src, A, 5 * B)
q_b = @query src |> orderby(A, 5 * B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# groupby

q_a = @query groupby(src, D)
q_b = @query src |> groupby(D)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query groupby(src, A > .5)
q_b = @query src |> groupby(A > .5)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

q_a = @query groupby(src, D, A > .5)
q_b = @query src |> groupby(D, A > .5)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# summarize

q_a = @query summarize(src, avg_A = mean(A))
q_b = @query src |> summarize(avg_A = mean(A))
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

### JOINS

src1 = MyData()
src2 = MyData()

# leftjoin

q_a = @query leftjoin(src1, src2, A = B)
q_b = @query src1 |> leftjoin(src2, A = B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# outerjoin

q_a = @query outerjoin(src1, src2, A = B)
q_b = @query src1 |> outerjoin(src2, A = B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# innerjoin

q_a = @query innerjoin(src1, src2, A = B)
q_b = @query src1 |> innerjoin(src2, A = B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

# crossjoin

q_a = @query crossjoin(src1, src2, A = B)
q_b = @query src1 |> crossjoin(src2, A = B)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

##################
# querying a Query

f(q::Query) = @query q |> select(B)
q_a = f(@query filter(src, A > .5))
q_b = @query filter(src, A > .5) |> select(B)
@test isequal(src, _src)
@test isequal(q_a, q_b)
show(io, q_a)
display(disp, q_a)

end
