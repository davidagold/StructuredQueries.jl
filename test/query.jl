module TestQuery
    using jplyr
    using Base.Test

    tbl1 = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6])
    )
    _tbl1 = copy(tbl1)

    # test filter
    tbl2 = @filter(tbl1, a > 2)
    qrya = @query filter(tbl1, a > 2)
    qryb = @query tbl1 |> filter(a > 2)
    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2, tbl2a)
    @test isequal(tbl2a, tbl2b)

    # test mutate
    tbl2 = @mutate(tbl1, c = a * b)
    qrya = @query mutate(tbl1, c = a * b)
    qryb = @query tbl1 |> mutate(c = a * b)
    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2, tbl2a)
    @test isequal(tbl2a, tbl2b)

    # test summarize
    tbl2 = @summarize(tbl1, b_avg = mean(b))
    qrya = @query summarize(tbl1, b_avg = mean(b))
    qryb = @query tbl1 |> summarize(b_avg = mean(b))
    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2, tbl2a)
    @test isequal(tbl2a, tbl2b)

end
