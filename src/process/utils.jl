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
