
struct Constraint{X}
    # Variables checked by this constraint
    uses :: Array{X,1}
    # Function to check if the constraint is satisfied.
    # Arguments need to be of domain type and passed in the order they are present in `uses`.
    checkfunction
end

struct Csp{X, D}
    variables :: Array{X,1}
    domains :: Array{D, 1}
    constraints :: Array{Constraint{X},1}
end

function cross(a, b)
    v = []
    for first in a
        for second in b
            push!(v, (first, second))
        end
    end
    return v
end

function stepnum(number :: UInt, step :: UUInt) :: UInt {
    floor(number / step) * step
}

# returns a list of all fields a given position on a sudoku grid
# needs to differ from
function related_fields(field :: (UInt, UInt)) :: Set{(UInt, UInt)}
    row = stepnum(field[2], 3)
    col = stepnum(field[1], 3)

    squares = cross(row:(row+3), col:(col+3))
    vertical = map(0:9) do y (field[1], y) end
    horizontal = map(0:9) do x (x, field[2]) end
    
    s = Set(squares..., vertical..., horizontal...)

    # fields musn't be unequal to iteself, so we remove it from the set
    delete!(s, field)

    s
end
    

function sudoko_csp() :: Csp{(UInt,UInt),UInt}
    variables = cross(0:9, 0:9)::Array{(UInt,UInt), 1}
    domains = 0:9
    constraints = begin
        variables |> map do var
            rel = related_fields(var)
            map(rel) do other Constraint([var, other], !=) end
        end
    end

    Csp(variables, domains, constraints)
end

sample = sudoko_csp()
