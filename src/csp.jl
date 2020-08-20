struct Constraint{X}
    # Variables checked by this constraint
    uses :: Array{X,1}
    # Function to check if the constraint is satisfied.
    # Arguments need to be of domain type and passed in the order they are present in `uses`.
    checkfunction
end

struct Csp{X, D}
    variables :: Array{X,1}
    domain :: Array{D, 1}
    constraints :: Array{Constraint{X},1}

    """
    Whether or not the constraints need to be switched around when performing arc consitency.
    I.e. if for a constraint (a, b) an equivalent constraint (b, a) exists, this needs to false.
    If unsure about it's usage, always leave unassigned (default is true).
    This is soley for perfomance reasons, while the algorithm wont work as intended, if this is wrongfully declared false.
    """
    inversefunctions :: Bool

    # Csp(
    #     variables :: Array{X,1},
    #     domain :: Array{D, 1},
    #     constraints :: Array{Constraint{X}, 1},
    #     inversefunctions = true,
    #     ) :: Csp{X, D} = new{Csp{X, D}}(variables, domain, constraints, inversefunctions)
end

function Csp(v, d, c)
    Csp(v, d, c, true)
end

function inverse(c :: Constraint{X}) :: Constraint{X} where X
    if length(c.uses) == 1
        return c
    elseif length(c.uses) == 2
        return Constraint(reverse(c.uses), (a, b) -> c.checkfunction(b, a))
    elseif length(c.uses) == 3
        return Constraint(reverse(c.uses), (a, b, c) -> c.checkfunction(c, b, a))
    end

    Constraint(reverse(c.uses), (args...) -> c.checkfunction(reverse(args)...))
end


function issolution(csp, assignment)
    d = Dict()
    for k in keys(assignment)
        # set of values
        domain = assignment[k]
        if length(domain) != 1
            return nothing
        end

        d[k] = domain |> collect |> first
    end

    # Check all constraints
    for constraint in csp.constraints
        args = constraint.uses .|> (var) -> d[var]
        if ! constraint.checkfunction(args...)
            return nothing
        end
    end

    d
end

# enforces arc consistency using the ac3 algorithm
# mutates assignment in the process
# returns false, if domain of one variable is empty
function ac3!(csp, assignment)
    # Constraints, possibly need to doubled
    constraints = csp.constraints
    if csp.inversefunctions
        constraints = vcat(constraints, map(inverse, constraints))
    end

    queue = constraints |> copy

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
                if domain(var) |> length == 0
                    return false
                end

                foreach(constraints) do c
                    if var in c.uses[2:end]
                        push!(queue, c)
                    end
                end
            end
        end
    end

    true
end



function backtrace(csp, assignment = nothing)
    if assignment === nothing
        assignment = Dict(var => Set(csp.domain) for var in csp.variables)
    end

    # enforce arc consistency
    # fail if one variable has an empty domain
    if ! ac3!(csp, assignment)
        return nothing
    end

    let s = issolution(csp, assignment)
        if s !== nothing
            return s
        end
    end

    # pick next variable to be assigned.
    # filter out all variables with domain size of 1, since these have a fixed assignment
    variables_left = filter(csp.variables) do key
        length(assignment[key]) > 1
    end

    # TODO clever heuristic, other than pick first one (e.g. MRV)
    var = first(variables_left)

    for d in csp.domain
        assignment[var] = Set(d)

        solution = backtrace(csp, copy(assignment))
        if solution !== nothing
            return solution
        end
    end

    return nothing
end
