module TestGroupBy
    using jplyr
    using Base.Test

    tbl = Table(
        name = ["Niamh", "Roger", "Genevieve", "Aiden"],
        age = [27, 63, 26, 17],
        eye_color = ["green", "brown", "brown", "blue"]
    )
    _tbl = copy(tbl)

    group_indices = Dict{Any, Vector{Int}}([
        ("brown",false) => [3],
        ("green",true)  => [1],
        ("brown",true)  => [2],
        ("blue",false)  => [4],
    ])

    qrya = @query groupby(tbl, eye_color, age > 26)
    qryb = @query tbl |> groupby(eye_color, age > 26)

    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl, _tbl)
    @test isequal(tbl2a, tbl2b)
    @test isequal(tbl2a.group_indices, group_indices)
    @test isequal(tbl2a.groupings, qrya.args)

end
