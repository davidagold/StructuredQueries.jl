"""
    parts(helper::QueryHelper)

Return the parts of the helper (this is usually a tuple of useful things,
e.g. a kernel generated from a query argument).
"""
function parts end

parts(helper::SelectHelper) = helper.res_field, helper.f, helper.arg_fields
parts(helper::FilterHelper) = helper.f, helper.arg_fields
parts(helper::GroupbyHelper) = helper.is_predicate, helper.f, helper.arg_fields
parts(helper::SummarizeHelper) = (
    helper.res_field,
    helper.f,
    helper.g,
    helper.arg_fields
)
