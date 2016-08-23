"""
"""
function find_parameters!(parameters, e::Expr)
    if e.head == :(::)
        push!(parameters, (e.args[1], e.args[2]))
    else
        for arg in e.args
            find_parameters!(parameters, arg)
        end
    end
    return
end

find_parameters!(parameters, e) = nothing

"""
A utility for selecting the name of a called function in a `:call` `Expr`.
"""
exf(ex) = ex.args[1]

"""
A utility for selecting the arguments to a function call in a `:call` `Expr`.
"""
exfargs(ex) = ex.args[2:end]
