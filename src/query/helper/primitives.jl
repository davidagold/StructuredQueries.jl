"""
    parts(helper::QueryHelper)

Return the parts of the helper (this is usually a tuple of useful things,
e.g. a kernel generated from a query argument).
"""
function parts end

parts(helper::SelectHelper) = helper.result_field, helper.f, helper.argument_fields
parts(helper::FilterHelper) = helper.f, helper.argument_fields
parts(helper::GroupbyHelper) = helper.is_predicate, helper.f, helper.argument_fields
parts(helper::SummarizeHelper) = (
    helper.result_field,
    helper.f,
    helper.g,
    helper.argument_fields
)
