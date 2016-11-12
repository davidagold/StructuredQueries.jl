# NOTE: filter is special because we may need to decompose into filter + joins
function build_node_ex!(stash, join_hist, ::Type{Filter}, args, index)
    join_arg_idxs, filter_arg_idxs = Vector{Int}(), Vector{Int}()
    process_args!(stash, join_hist, Filter, args, index)
end

"""

The strategy is to sort the args into filters that happen before the join,
join arguments, and filters that happen after the join.
"""
# NOTE: :filter has its own definition because it may be decomposed into
#       filters and join
function process_args!(stash, join_hist, ::Type{Filter}, exs, index)::Tuple{Expr, Set{Symbol}}
    # for an early (before join) filter -- i.e., a filters that only concerns a
    # single source -- we don't know join path until we inspect which source is used
    # map a source to a vector of args
    early_filters = Dict{Set{Symbol}, Vector{Expr}}()
    early_srcs_used = Set{Symbol}()

    join_srcs_used = Set{Symbol}()
    join_args = Vector{Expr}()
    join_helpers_ex = Expr(:ref, InnerJoin)

    # TODO: there may be late filters that join sources not involved in the join!!
    # Take care of those!!!
    # late_filter_srcs_used = Set{Symbol}()
    late_filter_args = Vector{Expr}()

    for ex in exs
        # look for equijoins
        if ex.head == :call && ex.args[1] == :(==)
            # NOTE: Not particurlaly efficient, should probably just check
            # whether join or filter and not build a helper_ex
            verb, srcs_used, helper_ex = join_or_filter(ex, join_hist, index)
            if verb == :join
                union!(join_srcs_used, srcs_used)
                push!(join_helpers_ex.args, helper_ex)
                push!(join_args, ex)
            elseif verb == :filter
                if length(srcs_used) == 1 # so, an early filter
                    _early_filter_args, = get!(
                        early_filters, srcs_used, Vector{Expr}()
                    )
                    push!(_early_filter_args, ex)
                    push!(early_srcs_used, first(srcs_used))
                else
                    push!(late_filter_args, ex)
                end
            end
        else # definitely a filter -- is it early or late?
            srcs_used = Set{Symbol}()
            # NOTE: Again, not efficient! Check for sources used, then build
            # f_ex later!
            f_ex = build_f_ex!(srcs_used, ex, index)
            helper_ex = Expr(:call, Filter, Expr(:tuple, f_ex))
            # check if the srcs_used have previously been joined, since this determines
            # whether the filter is early or late
            unique_src_hists = unique([ join_hist[src] for src in srcs_used ])
            if length(unique_src_hists) == 1 # early
                _early_filter_args = get!(
                    early_filters, first(unique_src_hists), Vector{Expr}()
                )
                push!(_early_filter_args, ex)
                union!(early_srcs_used, srcs_used)
            else # late
                push!(late_filter_args, ex)
            end
        end
    end

    # If there is no join, assume we can just throw everything in there ...
    # NOTE: But this throws away late filters, which is inconsistent with how
    # we handle unmerged join histories elsewhere.
    if length(join_args) == 0
        src_nodes_ex = Expr(:tuple)
        # if just an early join, should only be one src_hist
        # TODO: handle case where multipe src_hists (what should that behavior be?
        #       It should probably just error -- maybe we need a principle, that
        #       each manipulation verb must only return a single table)
        # @assert length(keys(early_filters)) == 1

        src_hist = first(keys(early_filters))
        push!(src_nodes_ex.args, stash[src_hist])
        _args = early_filters[src_hist]
        args = aggregate(_args)
        f_ex, ai = build_f_ex!(Set{Symbol}(), args, index)
        # @show f_ex
        helpers_ex = Expr(:ref, Filter, Expr(:call, Filter, f_ex, ai))
        early_filter_node_ex = Expr(
            :call, Node{Filter}, src_nodes_ex, _args, helpers_ex
        )

        return early_filter_node_ex, early_srcs_used
    end

    # if there is a join ...

    for src_hist in keys(early_filters)
        node_ex = stash[src_hist]
        _args = early_filters[src_hist]
        args = aggregate(_args)
        f_ex, ai = build_f_ex!(Set{Symbol}(), args, index)
        # @show f_ex
        helpers_ex = Expr(:ref, Filter, Expr(:call, Filter, f_ex, ai))
        stash[src_hist] = Expr(
            :call, Node{Filter}, Expr(:tuple, node_ex), _args, helpers_ex
        )
    end

    join_src_nodes_ex = Expr(:tuple)
    # unique should be redundant... TODO: straighten out this logic
    for src_hist in unique([ join_hist[src] for src in join_srcs_used ])
        push!(join_src_nodes_ex.args, stash[src_hist])
    end

    join_node_ex = Expr(
        :call, Node{:innerjoin}, join_src_nodes_ex,
        join_args, join_helpers_ex
    )

    # If there are late filters...
    if length(late_filter_args) > 0
        args = aggregate(late_filter_args)
        # TODO: don't throw away the sources used information
        f_ex, ai = build_f_ex!(Set{Symbol}(), args, index)
        helpers_ex = Expr(:ref, Filter, Expr(:call, Filter, f_ex, ai))
        late_filter_node_ex = Expr(
            :call, Node{Filter}, Expr(:tuple, join_node_ex), late_filter_args,
            helpers_ex
        )
        return late_filter_node_ex, join_srcs_used
    else
        return join_node_ex, join_srcs_used
    end

    # NOTE: We are assuming here that no late filters mention sources not
    # involved in the join AND that all sources involved in early filters are involved in the join

    # NOTE: Currently, one can include early filters that refer to histories that
    # are not referenced in the join and hence are not included in the resultant
    # node. We should raise a warning
end

"""

Decide whether a query arg that looks like `lhs == rhs` should belong to a
join node or to a filter node.
"""
function join_or_filter(ex, join_hist, index)::Tuple{Symbol, Set{Symbol}, Expr}
    srcs_used1, srcs_used2 = Set{Symbol}(), Set{Symbol}() # lhs, rhs
    lhs, rhs = ex.args[2], ex.args[3]
    f_ex1, arg_fields1 = build_f_ex!(srcs_used1, lhs, index)
    f_ex2, arg_fields2 = build_f_ex!(srcs_used2, rhs, index)
    nsrcs1, nsrcs2 = length(srcs_used1), length(srcs_used2)

    # check if histories of sources on each side are unmerged
    # (this would entail a non-equijoin, which are not currently supported)
    src_hists1 = unique([ join_hist[src] for src in srcs_used1 ])
    src_hists2 = unique([ join_hist[src] for src in srcs_used2 ])
    if (length(src_hists1) > 1) | (length(src_hists2) > 1)
        throw(ArgumentError("This type of join not (yet) supported."))
    end
    # now we know that each side's histories have been joined somewhere in past,
    # or one side refers to no sources (just literals or names from enclosing scope)
    if length(src_hists1) * length(src_hists2) == 0 # filter
        srcs_used = Set{Symbol}()
        f_ex = build_f_ex!(srcs_used, ex, index)
        return :filter, srcs_used,
               Expr(:call, Filter, Expr(:tuple, f_ex))
    else # join
        return :join, union(srcs_used1, srcs_used2),
            Expr(
                :call, InnerJoin,
                Expr(
                    :tuple, Expr(:tuple, f_ex1, f_ex2),
                    Expr(:tuple, arg_fields1, arg_fields2)
                )
            )
    end
end

aggregate(args) = foldl((x,y)->:( $x & $y ), args)
