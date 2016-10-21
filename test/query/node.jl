module TestQueryNode

using StructuredQueries
using Base.Test

io = IOBuffer()
disp = TextDisplay(IOBuffer())

type MyData end
iris = MyData()

q = @query filter(iris, sepal_length > 5.0)
@test source(q) === iris
@test graph(q) === q.graph
show(io, graph(q))
display(disp, graph(q))

q = @query iris |>
    filter(sepal_length > 5.0) |>
    select(petal_width)
@test source(q) === iris
@test graph(q) === q.graph
show(io, graph(q))
display(disp, graph(q))

q = @query iris |>
    filter(sepal_length > 5.0) |>
    groupby(species) |>
    summarize(avg = mean(petal_width))
@test source(q) === iris
@test graph(q) === q.graph
show(io, graph(q))
display(disp, graph(q))

tbl1, tbl2 = MyData(), MyData()

q = @query tbl1 |>
    select(A, B) |>
    leftjoin(filter(tbl2, C > .5), A == B) |>
    groupby(D) |>
    summarize(avg = mean(E))
@test source(q) === (tbl1, tbl2)
@test graph(q) === q.graph
show(io, graph(q))
display(disp, graph(q))

q = @query tbl1 |>
    select(A, B) |>
    leftjoin(filter(tbl2, C > .5), A == B) |>
    groupby(D) |>
    crossjoin(tbl1)
@test source(q) === ((tbl1, tbl2), tbl1)
@test graph(q) === q.graph
show(io, graph(q))
display(disp, graph(q))

end
