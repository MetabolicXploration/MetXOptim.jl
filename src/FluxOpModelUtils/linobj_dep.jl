# tell if a flux is positive proporto or negatively prop the given lin obj
export linobj_dependence
function linobj_dependence(opm::FluxOpModel; rtol = 1e-5)
    # sense 1
    optimize!(opm)
    sol1 = solution(opm)
    
    # sense -1
    lin_objective!(opm, -1 .* lin_objective(opm))
    optimize!(opm)
    sol2 = solution(opm)
    
    # restore
    lin_objective!(opm, -1 .* lin_objective(opm))

    return map(zip(sol1,sol2)) do (s1, s2)
        isapprox(s1, s2; rtol) && return 0
        s1 > s2 && return 1
        s1 < s2 && return -1
    end 
end