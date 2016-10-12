parts(helper::SelectHelper) = helper.res_field, helper.f, helper.arg_fields
parts(helper::FilterHelper) = helper.f, helper.arg_fields
parts(helper::GroupbyHelper) = helper.is_predicate, helper.f, helper.arg_fields
parts(helper::SummarizeHelper) = (
    helper.res_field,
    helper.f,
    helper.g,
    helper.arg_fields
)
