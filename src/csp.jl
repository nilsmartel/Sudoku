
using LinearAlgebra.cross

struct CSP{V, T}
    variables :: Array{String,1}
    domains :: Array{T, 1}
    constraints
end

function sudoko_csp() :: CSP{(UInt,UInt),UInt}
    variables = cross(0:9, 0:9) .|> map do (x, y)

    
