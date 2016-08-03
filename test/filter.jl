module TestFilter
    using jplyr
    using Base.Test

    tbl1 = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6])
    )
    _tbl1 = copy(tbl1)
    tbl_fin = Table(
        a = NullableArray([3]),
        b = NullableArray([6])
    )

    tbl2a = @filter(tbl1, a > 2)
    tbl2b = tbl1 |> @filter(a > 2)
    # test that @filter didn't mutate original table
    @test isequal(tbl1, _tbl1)
    # test that @filter returns desired result
    @test isequal(tbl2a, tbl_fin)
    # test that piped and non-piped versions return identical results
    @test isequal(tbl2a, tbl2b)
end
