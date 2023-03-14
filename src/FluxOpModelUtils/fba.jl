## ------------------------------------------------------------------
# Just a wrapper that add all the basic constraints of FBA
export FBAFluxOpModel
function FBAFluxOpModel(
        S::AbstractMatrix, b::AbstractVector, 
        lb::AbstractVector, ub::AbstractVector, 
        c::AbstractVector, 
        jump_args...
    )::FluxOpModel

    # TODO: Add some checks (dims, types, etc)

    jpm = JuMP.Model(jump_args...)
    opm = FluxOpModel(jpm)
    JuMP.set_silent(jpm)

    set_jpvars!(opm, size(S, 2))
    
    set_lower_bound_cons!(opm, lb)
    set_upper_bound_cons!(opm, ub)
    set_balance_cons!(opm, S, b)

    set_linear_obj!(opm, c)
    
    return opm
end

## ------------------------------------------------------------------
# fba
export fba, fba!
function fba!(opm::FluxOpModel) 
    # We can not assume that the current obj is the linear
    set_linear_obj!(opm)
    
    optimize!(opm)
    return opm
end
