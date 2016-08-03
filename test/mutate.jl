module TestMutate
    using jplyr
    using Base.Test

    tbl1 = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6])
    )
    _tbl1 = copy(tbl1)
    tbl_fin = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6]),
        c = NullableArray([4, 10, 18])
    )

    tbl2a = @mutate(tbl1, c = a * b)
    tbl2b = tbl1 |> @mutate(c = a * b)

    # test that @mutate didn't mutate original table
    @test isequal(tbl1, _tbl1)
    # test that @mutate returns desired result
    @test isequal(tbl2a, tbl_fin)
    # test that piped and non-piped versions return identical results
    @test isequal(tbl2a, tbl2b)
end
