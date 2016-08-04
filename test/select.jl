module TestSelect
    using jplyr
    using Base.Test

    tbl1 = Table(
        a = NullableArray([1, 2, 3]),
        b = NullableArray([4, 5, 6]),
        c = NullableArray(["a", "b", "c"]),
        d = NullableArray([:a, :b, :c])
    )
    _tbl1 = copy(tbl1)

    for (fld, col) in eachcol(tbl1)
        @eval tbl2a = @select(tbl1, $fld)
        @eval tbl2b = tbl1 |> @select($fld)
        @test isequal(tbl1, _tbl1)
        @test isequal(
            tbl2a,
            @eval Table($fld = $col)
        )
        @test isequal(tbl2a, tbl2b)
    end

    # test to make sure that conflicting names don't throw piped @select
    a = [1, 2, 3]
    b = [:a, :b, :c]
    tbl1 = Table(a = a, b = b)
    _tbl1 = copy(tbl1)
    tbl2a = @select(tbl1, a)
    tbl2b = tbl1 |> @select(a)
    @test isequal(tbl1, _tbl1)
    @test isequal(tbl2a, Table(a = a))
    @test isequal(tbl2a, tbl2b)
end
