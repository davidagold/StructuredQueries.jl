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
