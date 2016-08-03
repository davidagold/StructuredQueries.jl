module TestSummarize
    using jplyr
    using Base.Test

    tbl1 = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6])
    )
    _tbl1 = copy(tbl1)
    tbl_fin = Table(
        b_avg = NullableArray([mean([4, 5, 6])])
    )

    tbl2a = @summarize(tbl1, b_avg = mean(b))
    tbl2b = tbl1 |> @summarize(b_avg = mean(b))

    # test that @summarize didn't mutate original table
    @test isequal(tbl1, _tbl1)
    # test that @summarize returns desired result
    @test isequal(tbl2a, tbl_fin)
    # test that piped and non-piped versions return identical results
    @test isequal(tbl2a, tbl2b)
end
