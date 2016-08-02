# TODO: Decide whether to provide both @mutate! vs @mutate macros.
# TODO: Make a copy before mutating the copy.
macro mutate(input::Symbol, _args::Expr...)
    args = collect(_args)
    mutate_helper_ex = _build_helper_ex(MutateNode, args)
    return quote
        g = MutateNode(DataNode($(esc(input))), $args, $mutate_helper_ex)
        _collect(g)
    end
end

macro mutate(_args::Expr...)
    args = collect(_args)
    mutate_helper_ex = _build_helper_ex(MutateNode, args)
    return quote
        g = MutateNode(DataNode(), $args, $mutate_helper_ex)
        _collect(CurryNode(), g)
    end
end

function _build_helper_ex(::Type{MutateNode}, args)
    helper_args_ex = Expr(:ref, :Tuple)
    mutate_helper_ex = Expr(:call, :MutateHelper, helper_args_ex)
    for e in args
        res_fld = QuoteNode(_get_column_name(e))
        core_expr = _get_core_expr(e)
        anon_func_expr, reverse_mapping = _build_anon_func(core_expr)
        helper_parts_ex = Expr(:tuple, res_fld, anon_func_expr, esc(reverse_mapping))
        push!(helper_args_ex.args, helper_parts_ex)
    end
    return mutate_helper_ex
end
