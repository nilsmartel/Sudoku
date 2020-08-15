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

    Csp(variables, domains, vcat(constraints...))
end

function issolution(csp, assignment :: Dict{Tuple{Int, Int}, Set{Int}})
    d = Dict{Tuple{Int, Int}, Int}()
    for k in keys(assignment)
        v = assignment[k]
        if length(v) != 1
            return nothing
        end

        d[k] = keys(v.dict)[1]
    end

    for constraint::Constraint in csp.constraints
        args = constraint.uses .|> var -> d[var]
        if ! csp.checkfunction(args...)
            return nothing
        end
    end

    d
end

# enforces arc consistency using the ac3 algorithm
function ac3(csp, assignment)
    assignment = assignment |> deepcopy
    queue = csp.constraints |> copy

    function domain(var)
        assignment[var]
    end

    # removes a value from domain of a variable
    function remove(var, value)
        setdiff!(assignment[var], [value])
    end

    for cs in queue
        var = cs.uses[1]
        f = cs.checkfunction
        for value in domain(var)
            some = [v2 for v2 in domain(cs.uses[2]) if f(value, v2)]
            if length(some) == 0
                # mutation of assignment
                remove(var, value)

                foreach(csp.constraints) do c
                    if var in c.uses[2:end]
                        push!(queue, c)
                    end
                end
            end
        end
    end

    assignment
end



function backtrace(csp, assignment :: Dict{Tuple{Int, Int}, Set{Int}})
    assignment = ac3(csp, assignment)
    let s = issolution(csp, assignment)
        if s !== nothing
            return s
        end
    end

    # pick next variable to be assigned
    # TODO: MRV or something clever
    v = filter(assignment |> values) do key
        size(assignment[key]) > 1
    end |> first

    for d in csp.domain
        assignment[v] = d

        solution = backtrace(csp, copy(assignment))
        if solution !== nothing
            return solution
        end
    end

    return nothing
end

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
