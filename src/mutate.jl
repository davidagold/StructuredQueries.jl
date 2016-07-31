include("mutate/01_expr.jl")
include("mutate/02_fill.jl")
include("mutate/03_apply.jl")
include("mutate/04_make_funcs.jl")

# TODO: Decide whether to provide both @mutate! vs @mutate macros.
# TODO: Make a copy before mutating the copy.
macro mutate(input, _args...)
    args = collect(_args)
    helper_args_ex = Expr(:vect)
    mutate_helper_ex = Expr(:call, :MutateHelper, helper_args_ex)
    for e in args
        res_fld = QuoteNode(_get_column_name(e))
        core_expr = _get_core_expr(e)
        anon_func_expr, reverse_mapping = _build_anon_func(core_expr)
        hlpr_parts_ex = Expr(:tuple, res_fld, anon_func_expr, esc(reverse_mapping))
        push!(helper_args_ex.args, hlpr_parts_ex)
    end
    return quote
        hlpr = $mutate_helper_ex
        g = MutateNode(DataNode($(esc(input))), $args, hlpr)
        _collect(g)
    end
end

# TODO: support piped inputs

function _collect(tbl::AbstractTable, g::MutateNode)
    hlpr = g.hlpr
    for (res_fld, lambda, arg_flds) in hlpr.hlprs
        tbl[res_fld] = _apply_tuple_func(lambda, tbl, arg_flds)
    end
    tbl
end
