module TestQuery
    using jplyr
    using Base.Test

    a = NullableArray([1, 2, 3])
    b = NullableArray([4, 5, 6])
    c = NullableArray(["a", "b", "c"])
    d = NullableArray([:a, :b, :c])
    tbl1 = Table(
        a = a,
        b = b,
        c = c,
        d = d
    )
    _tbl1 = copy(tbl1)

    # test select
    for (fld, col) in eachcol(tbl1)
        @eval qrya = @query select(tbl1, $fld)
        @eval qryb = @query tbl1 |> select($fld)
        tbl2a = collect(qrya)
        tbl2b = collect(qryb)
        @test isequal(tbl1, _tbl1)
        @test isequal(
            tbl2a,
            @eval Table($fld = $col)
        )
        @test isequal(tbl2a, tbl2b)
    end

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
    tbl2 = @mutate(tbl1, e = a * b)
    qrya = @query mutate(tbl1, e = a * b)
    qryb = @query tbl1 |> mutate(e = a * b)
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

    # test combinations
    tbl_fin = @filter(tbl1, a == 1) |> @select(b)
    qrya = @query select(filter(tbl1, a == 1), b)
    qryb = @query tbl1 |>
        filter(a == 1) |>
        select(b)
    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2a, tbl_fin)
    @test isequal(tbl2a, tbl2b)
end
