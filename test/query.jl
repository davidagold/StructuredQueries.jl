module TestQuery
    using jplyr
    using Base.Test

    a = [1, 2, 3]
    b = [4, 5, 6]
    c = ["a", "b", "c"]
    d = [:a, :b, :c]
    tbl1 = Table(
        a = NullableArray(a),
        b = NullableArray(b),
        c = NullableArray(c),
        d = NullableArray(d)
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

    tbl2 = @select(tbl1, f = a * b)
    qrya = @query select(tbl1, f = a * b)
    qryb = @query tbl1 |> select(f = a * b)
    tbl2a = collect(qrya)
    tbl2b = collect(qryb)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2, tbl2a)
    @test isequal(tbl2a, tbl2b)

    # test filter
    tbl2 = @filter(tbl1, a > 2)
    qrya = @query filter(tbl1, a > 2)
    qryb = @query tbl1 |> filter(a > 2)
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
