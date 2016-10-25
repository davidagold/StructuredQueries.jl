# using TablesDemo
# tbl = Table(
#     A = NullableArray(rand(10)),
#     B = NullableArray(rand(10))
# )


@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.A  > .6)
end

@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.A * j.B > .6)
end

@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.C < .5, i.D == k.D, j.D == "dplyr", k.D == h.D, k.E > .5, h.F == "pandas")
end

# TODO: make the following raise a warning because of unjoined i path
@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.C < .5, j.D == "dplyr", k.D == h.D, k.E > .5, h.F == "pandas")
end

# NOTE: should also raise a warning, but the i path gets joined
@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.C < .5, j.D == "dplyr", k.D == h.D, k.E > .5, h.F == "pandas")
    join(i.D == k.D)
end

# NOTE: should also raise a warning, but the i path gets joined
@with df1(i), df2(j), df3(k), df4(h) do
    filter(i.A > .5, i.B == j.B, j.C < .5)
    filter(i.C < .5, j.D == "dplyr", k.D == h.D, k.E > .5, h.F == "pandas")
    join(i.D == k.D)
    groupby(f(i.A) < .5, k.D, g(j.B * k.C))
end

# NOTE: currently errors, but should probably just raise a warning if the above
#       only raise warnings
@with df1(i), df2(j) do
    filter(i.A > .5, j.B < .5)
end

# NOTE: The following errors because our join algorithm doesn't yet support this
#       type of join
@with df1(i), df2(j) do
    filter(i.A * j.B == .5)
end
