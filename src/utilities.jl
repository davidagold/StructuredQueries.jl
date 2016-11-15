"""
    call_function(ex)

Return the name of a called function in a `:call` `Expr`.
"""
call_function(ex) = ex.args[1]

"""
    call_function_arguments(ex)

Return the arguments to a function call in a `:call` `Expr`.
"""
call_function_arguments(ex) = ex.args[2:end]
