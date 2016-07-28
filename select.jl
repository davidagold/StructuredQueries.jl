# Take in Dict{NullableVector} and expressions, figure out which
# columns are needed and generate anonymous functions.

# Extract columns

# Evaluate anonymous functions on columns.


function do_stuff(f, cols)
    t = Core.Inference.return_type(f, map(eltype, cols))
    # If concrete, do the fast thing.
        # Allocate output
        n = length(cols[1])
        output = Array(t, n)
        for i in 1:n
            output[i] = f(cols[1][i], cols[2][i])
        end
    # Otherwise do the potentially slow thing.
    return output
end

do_stuff((x, y) -> x + y, ([1, 2, 3], [1.0, 2.0, 3.0]))
do_stuff((x, y) -> x + y, (zeros(Int, 1_000), zeros(Int, 1_000)))
@time do_stuff(
    (x, y) -> x + y,
    (
        zeros(Int, 1_000_000),
        zeros(Int, 1_000_000)
    ),
)
