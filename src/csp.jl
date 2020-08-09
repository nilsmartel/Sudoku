
using LinearAlgebra.cross

struct Constraint{X}
    # Variables checked by this constraint
    uses :: Array{X,1}
    # Function to check if the constraint is satisfied.
    # Arguments need to be passed in the order they are present in `uses`.
    # Fn(...D) -> Boolean
    check_function
end

struct CSP{X, D}
    variables :: Array{X,1}
    domains :: Array{D, 1}
    constraints :: Array{Constraint{X},1}
end

function sudoko_csp() :: CSP{(UInt,UInt),UInt}
    variables = cross(0:9, 0:9) .|> map do (x, y)
    domains = 0:9
    constraints
end