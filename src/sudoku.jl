include("csp.jl")

struct Sudoko
    assignment :: Dict{Tuple{Int, Int}, Int}
end

function solve_sudoko(field :: Sudoko)
    assignmentset = Dict((a,b) => Set(1:9) for a in 1:9, b in 1:9) :: Dict{Tuple{Int, Int}, Set{Int}}

    for key in keys(field.assignment)
        value = field.assignment[key]
        assignmentset[key] = Set(value)
    end

    backtrace(sudoko_csp(), assignmentset)
end

"""
Util function from now on
"""

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
    row = stepnum(field[2]-1, 3)+1
    col = stepnum(field[1]-1, 3)+1

    squares = cross(row:(row+2), col:(col+2)) :: Array{Tuple{Int, Int}, 1}
    vertical = map(1:9) do y
        (field[1], y)
    end

    horizontal = map(1:9) do x
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
    variables = cross(1:9, 1:9) # ::Array{Tuple{Int,Int}, 1}
    domains = 1:9 |> collect
    constraints = begin
        variables .|> (var) -> begin
            rel = related_fields(var) |> collect

            rel .|> r -> Constraint([var, r], unequal)
        end
    end

    Csp(variables, domains, vcat(constraints...), false)
end
