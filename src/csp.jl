
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

function cross(a, b) ::Array{Tuple{Int, Int}, 1}
    v = []
    for first in a
        for second in b
            push!(v, (first, second))
        end
    end
    return v
end

function stepnum(number :: Int, step :: Int) :: Int
    floor(number / step) * step
end

# returns a list of all fields a given position on a sudoku grid
# needs to differ from
function related_fields(field :: Tuple{Int, Int}) :: Set{Tuple{Int, Int}}
    row = stepnum(field[2], 3)
    col = stepnum(field[1], 3)

    squares = cross(row:(row+3), col:(col+3)) :: Array{Tuple{Int, Int}, 1}
    vertical = map(0:9) do y
        (field[1], y)
    end

    horizontal = map(0:9) do x
        (x, field[2])
    end

    s = Set([squares..., vertical..., horizontal...]) :: Set{Tuple{Int, Int}}

    # fields musn't be unequal to themselfs, so we remove it from the set
    delete!(s, field)

    s
end

function unequal(a :: Int, b :: Int) :: Bool
    a != b
end

function flatten(array)
    r = []
    for sub in array
        for elem in sub
            push!(r, elem)
        end
    end

    r
end

function sudoko_csp() :: Csp{Tuple{Int,Int},Int}
    variables = cross(0:9, 0:9) # ::Array{Tuple{Int,Int}, 1}
    domains = 0:9 |> collect
    constraints = begin
        variables .|> (var) -> begin
            rel = related_fields(var) |> collect

            rel .|> r -> Constraint([var, r], unequal)
        end
    end

    Csp(variables, domains, vcat(constraints...))
end

sample = sudoko_csp()
