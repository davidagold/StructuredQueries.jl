module TestQueryNode

using StructuredQueries
using Base.Test

io = IOBuffer()
disp = TextDisplay(IOBuffer())

type MyData end
iris = MyData()

c = @with iris filter(sepal_length > 5.0)
@test source(c) === (iris,)
@test graph(c) === c.graph
show(io, graph(c))
display(disp, graph(c))

c1 = @with iris begin
    filter(sepal_length > 5.0)
    select(petal_width)
end
c2 = @with iris filter(sepal_length > 5.0), select(petal_width)
@test isequal(c1, c2)
@test source(c1) === (iris,)
@test graph(c1) === c1.graph
show(io, graph(c1))
display(disp, graph(c1))

c1 = @with iris begin
    filter(sepal_length > 5.0)
    groupby(species)
    summarize(avg = mean(petal_width))
end
c2 = @with iris filter(sepal_length > 5.0),
    groupby(species),
    summarize(avg = mean(petal_width))
@test isequal(c1, c2)
@test source(c1) === (iris,)
@test graph(c1) === c1.graph
show(io, graph(c1))
display(disp, graph(c1))

end
