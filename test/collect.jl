module TestCollect

using StructuredQueries
using Base.Test

type MyData
    count::Int
end
StructuredQueries._collect(src::Tuple{MyData}, q::StructuredQueries.Node) =
    MyData(first(src).count+1)
StructuredQueries.prepare(src::MyData) = src
Base.collect(src::MyData) = src

src = MyData(0)

res = collect(@with src select(i))
@test res.count == 1

res = collect(@with src begin
    filter(i * j > k)
    select(l)
end)
@test res.count == 2

res = collect(@with src begin
    filter(sepal_length > 5.0)
    groupby(species)
    summarize(avg = mean(petal_width))
end)
@test res.count == 3

end
