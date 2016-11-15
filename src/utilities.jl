"""
    call_function(ex)

Return the name of a called function in a `:call` `Expr`.
"""
call_function(ex) = ex.args[1]

"""
    call_functionargs(ex)

Return the arguments to a function call in a `:call` `Expr`.
"""
call_functionargs(ex) = ex.args[2:end]
