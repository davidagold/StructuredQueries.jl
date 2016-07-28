module TBL

    tbl = Dict{Symbol, Vector}(
        :a => [1, 2, 3],
        :b => [4, 5, 6],
        :c => [7.0, 8.0, 9.0],
    )

    # @select(tbl, d = a + b)
    # @select(tbl, e = a + b * c)

    # TODO: Make this a function of tuples to avoid splatting
    # Go through expression and replace everything with tuple indices
    # gensym() a name like tpl
    # Then map a = b + c
    # to tpl -> tpl[1] + tpl[2]

    # Then extract columns from table
    # Then place them all in a zip iterator that generates tuples
    # First pass, extract new column name

    f = (a_i, b_i) -> a_i + b_i
    cols = tbl[:a], tbl[:b]
    t = Core.Inference.return_type(f, map(eltype, cols))
    n = length(cols[1])
    if isleaftype(t)
        res = Array(t, n)
        execute_tuple_func!(res, f, zip(cols...))
        tbl[:d] = res
    else
        error("Freak out over non-concrete types")
    end

    function execute_tuple_func!(res, f, tuple_generator)
        for (i, tpl) in enumerate(tuple_generator)
            res[i] = f(tpl...)
        end
        return
    end

end
