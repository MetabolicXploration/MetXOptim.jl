# tell if a flux is positive proporto or negatively prop the given lin obj
export objective_dependence
function _objective_dependence(opm::OpModel, rtol)
    
    # sense 1
    set_objective_sense!(opm, MAX_SENSE)
    optimize!(opm)
    sol1 = solution(opm)
    
    # sense -1
    set_objective_sense!(opm, MIN_SENSE)
    optimize!(opm)
    sol2 = solution(opm)

    return map(zip(sol1,sol2)) do (s1, s2)
        isapprox(s1, s2; rtol) && return 0
        s1 > s2 && return 1
        s1 < s2 && return -1
    end 
end

objective_dependence(opm::OpModel; rtol = 1e-5) =
    keepobj(() -> _objective_dependence(opm, rtol), opm) 