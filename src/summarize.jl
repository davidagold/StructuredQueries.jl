macro summarize(tbl_name::Symbol, _exprs...)
    exprs = collect(_exprs)
    g = SummarizeNode(DataNode(), exprs)
    helper_ex = build_helper_ex(g)
    return quote
        set_helper!($g, $helper_ex)
        _collect($(esc(tbl_name)), $g)
    end
end

macro summarize(_exprs...)
    exprs = collect(_exprs)
    g = SummarizeNode(DataNode(), exprs)
    helper_ex = build_helper_ex(g)
    return quote
        set_helper!($g, $helper_ex)
        _collect(CurryNode(), $g)
    end
end

### Helper

function build_helper_ex(g::SummarizeNode)
    check_node(g)
    helper_parts_ex = Expr(:ref, :Tuple, build_helper_parts(g)...)
    return quote
        Helper{SummarizeNode}($helper_parts_ex)
    end
end

function build_helper_parts(g::SummarizeNode)
    helper_parts_exs = Vector{Expr}()
    for e in g.args
        res_fld = QuoteNode(get_res_field(e))
        # Extract the first layer, which we assume is the summarization function
        new_e = e.args[2]
        @assert new_e.head == :call
        g_name = new_e.args[1]
        core_expr = new_e.args[2]
        kernel_expr, ind2sym = build_kernel_ex(core_expr)
        push!(helper_parts_exs,
              :( ($res_fld, $kernel_expr, $(esc(g_name)), $ind2sym) )
        )
    end
    return helper_parts_exs
end

function check_node(g::SummarizeNode)
    for e in g.args
        @assert isa(e, Expr)
        @assert e.head == :kw
        @assert e.args[2].head == :call
    end
    return
end

### RHS

@noinline function rhs_summarize(f, g, tbl, arg_flds)
    # Pre-process table w/r/t row kernel and argument column names
    T, row_itr = _preprocess(f, tbl, arg_flds)

    # Allocate a temporary column.
    temporary = Array(T, 0)

    # Fill the new column in row-by-row, skipping nulls.
    grow_nonnull_output!(temporary, f, row_itr)

    # Return the summarization function applied to the temporary.
    return NullableArray([g(temporary)])
end

"""
Grow non-null values.
"""
@noinline function grow_nonnull_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if !hasnulls(tpl)
            push!(output, f(map(unwrap, tpl)))
        end
    end
    return
end
