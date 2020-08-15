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

function issolution(csp, assignment)
    d = Dict()
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
# mutates assignment in the process
# returns false, if domain of one variable is empty
function ac3!(csp, assignment)
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

                # if no values are left in domain of variable
                # stop AC-3.
                if assignment[var] |> length == 0
                    return false
                end

                foreach(csp.constraints) do c
                    if var in c.uses[2:end]
                        push!(queue, c)
                    end
                end
            end
        end
    end

    true
end



function backtrace(csp, assignment, depth = 1)
    println("depth = $depth")

    # enforce arc consistency
    # fail if one variable has an empty domain
    if ! ac3!(csp, assignment)
        println("Arc consistency ruled out feasable domains")
        return nothing
    end

    let s = issolution(csp, assignment)
        if s !== nothing
            return s
        end
    end

    # pick next variable to be assigned.
    # filter out all variables with domain size of 1, since these have a fixed assignment
    variables_left = filter(keys(assignment)) do key
        length(assignment[key]) > 1
    end

    # TODO clever heuristic, other than pick first one (e.g. MRV)
    var = first(variables_left)

    for d in csp.domain
        assignment[var] = d

        solution = backtrace(csp, copy(assignment), depth+1)
        if solution !== nothing
            return solution
        end
    end

    return nothing
end

