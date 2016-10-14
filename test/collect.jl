module TestCollect

using StructuredQueries
using Base.Test

type MyData
    count::Int
end
StructuredQueries._collect(src::MyData, q::StructuredQueries.QueryNode) =
    MyData(src.count+1)
Base.collect(src::MyData) = src

src = MyData(0)

res = @collect select(src, i)
@test res.count == 1
res = @collect src |>
    filter(i * j > k) |>
    select(l)
@test res.count == 2
res = @collect src |>
    filter(sepal_length > 5.0) |>
    groupby(species) |>
    summarize(avg = mean(petal_width))
@test res.count == 3

end
