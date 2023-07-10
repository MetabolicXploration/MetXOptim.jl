import JuMP.optimize!
function optimize!(opm::AbstractOpModel; kwargs...) 
    jpm = jump(opm)
    JuMP.optimize!(jpm; kwargs...)
    _solution!(jpm) # save solution
    return opm
end

function tryoptimize!(opm::AbstractOpModel; kwargs...) 
    jpm = jump(opm)
    try
        JuMP.optimize!(jpm; kwargs...)
        _solution!(jpm) # save solution
    catch err
        _solution!(jpm, Float64[]) # save solution
    end
    return opm
end