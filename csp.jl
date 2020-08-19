struct Constraint
    # Variables checked by this constraint
    uses :: Array{X,1}
    # Function to check if the constraint is satisfied.
    # Arguments need to be of domain type and passed in the order they are present in `uses`.
    check
end

function variables(c :: Constraint)
    c.uses
end

function unaryConstraints(constraints)
    filter(constraints) do c
        length(variables(c)) == 1
    end
end

function inverse(c :: Constraint{X}) :: Constraint{X} where X
    if length(c.uses) == 1
        return c
    elseif length(c.uses) == 2
        return Constraint(reverse(c.uses), (a, b) -> c.check(b, a))
    elseif length(c.uses) == 3
        return Constraint(reverse(c.uses), (a, b, c) -> c.check(c, b, a))
    end

    Constraint(reverse(c.uses), (args...) -> c.check(reverse(args)...))
end

struct Csp{X, D}
    variables
    domain
    constraints

    """
    Whether or not the constraints need to be switched around when performing arc consitency.
    I.e. if for a constraint (a, b) an equivalent constraint (b, a) exists, this needs to false.
    If unsure about it's usage, always leave unassigned (default is true).
    This is soley for perfomance reasons, while the algorithm wont work as intended, if this is wrongfully declared false.
    """
    inversefunctions :: Bool
end

function Csp(v, d, c)
    Csp(v, d, c, true)
end


# returns false if no solution can be found
function ac3(csp, domain, constraints)
    # todo enforce unary constraints

    # list of constraints with more than one variable
    cons = filter(c -> variables(c) |> length > 1,constraints)
    # turn constraints into binary ones
    if csp.inversefunctions
        append!(cons, cons .|> inverse)
    end

    worklist = copy(cons)

    function remove(var, elem)
        setdiff!(domain[var], Set(elem))
    end

    for c in worklist
        var1 = variables(c) |> first

        var2 = variables(c)[2]
        for d in domain[var1]

            for d2 in domain[var2]
                if c.check(d, d2) == false
                    remove(var1, d)

                    if domain[var1] |> length == 0
                        return false
                    end

                    append!(worklist, filter(c -> variables(c)[2] == var1, cons))
                    break
                end
            end
        end
    end

    return true
end
