"""
    exf(ex)

Return the name of a called function in a `:call` `Expr`.
"""
exf(ex) = ex.args[1]

"""
    exfargs(ex)

Return the arguments to a function call in a `:call` `Expr`.
"""
exfargs(ex) = ex.args[2:end]

name(x::Symbol) = string(x)
name(x::DataType) = name(x.name)
name(x::TypeName) = string(x.name)
# name(x::DataType) = name(x.name, x.parameters)
# name(x::TypeName, parameters) =
#     length(parameters) > 0 ? string(x.name, "{:$(parameters[1])}") : string(x.name)
