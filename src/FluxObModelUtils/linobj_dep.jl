# tell if a flux is positive proporto or negatively prop the given lin obj
export linobj_dependence
function linobj_dependence(opm::FluxOpModel)
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
        s1 > s2 && return 1
        s1 < s2 && return -1
        return 0
    end 
end