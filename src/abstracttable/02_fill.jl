"""
TODO: Check if this function (which potentially has to do run-time method
dispatch) is a bottleneck. If there were no uncertainty whether elements were
going to be Nullable, that could be resolved.
"""
@inline function _hasnulls(itr::Any)
    res = false
    for el in itr
        if isa(el, Nullable)
            res |= isnull(el)
        end
    end
    return res
end

"""
Like get(x::Nullable), but applicable to all types. Also unsafe, so
conditional on some checks happening before this point.
"""
@inline _unwrap(x::Nullable) = x.value
@inline _unwrap(x::Any) = x

"""
Fill a NullableArray with the results of evaluating a tuple-to-scalar
function over a sequence of tuples generator by an iterator object.
In order to automatically implement lifting, we check  whether any element of
the tuple is nullable and (conditional on being nullable) null-valued.
"""
@noinline function _fill_output!(output, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # Automatically lift the function f here.
        if _hasnulls(tpl)
            # TODO: See if we can get away with an @inbounds annotation here.
            # NOTE: @inbounds seems to buy us nothing.
            output.isnull[i] = true
        else
            output.isnull[i] = false
            output.values[i] = f(map(_unwrap, tpl))
        end
    end
    return
end

"""
 +Grow a list of indices satisfying the predicate.
"""
@noinline function _grow_output!(indices, f, tpl_itr)
    for (i, tpl) in enumerate(tpl_itr)
        # We only include positive results,
        # which do not include NULL as predicate value.
        if !_hasnulls(tpl) && f(map(_unwrap, tpl))::Bool
            push!(indices, i)
        end
    end
    return
 end

 """
 Grow non-null values.
 """
 @noinline function _grow_nonnull_output!(output, f, tpl_itr)
     for (i, tpl) in enumerate(tpl_itr)
         # Automatically lift the function f here.
         if !_hasnulls(tpl)
             push!(output, f(map(_unwrap, tpl)))
         end
     end
     return
 end

 function fill_new_col!(new_col, col, indices)
     for (new_ind, old_ind) in enumerate(indices)
         if col.isnull[old_ind]
             new_col.isnull[new_ind] = true
         else
             new_col.isnull[new_ind] = false
             new_col.values[new_ind] = col.values[old_ind]
         end
     end
     return
 end

 function _get_subset{T}(tbl::T, indices)
     new_tbl = T()
     n = length(indices)
     for (col_name, col) in eachcol(tbl)
         new_col = NullableArray(eltype(eltype(col)), n)
         fill_new_col!(new_col, col, indices)
         new_tbl[col_name] = new_col
     end
     return new_tbl
 end
