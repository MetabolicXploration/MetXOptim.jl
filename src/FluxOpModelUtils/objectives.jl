## ------------------------------------------------------------------------------
# It MAXIMIZE c' * v[idx]
export set_linear_obj!
function set_linear_obj!(opm::FluxOpModel, idx, c)
    v = get_jpvars(opm, idx)
    @JuMP.objective(jump(opm), MOI.MAX_SENSE, c' * v)
    return opm
end

# It MAXIMIZE c'*v
function set_linear_obj!(opm::FluxOpModel, c::AbstractVector)
    v = get_jpvars(opm)
    @JuMP.objective(jump(opm), MOI.MAX_SENSE, c' * v)
    return opm
end

set_linear_obj!(opm::FluxOpModel, net::MetNet) = 
    set_linear_obj!(opm, lin_objective(net))

## ------------------------------------------------------------------------------
export set_v2_obj!
function set_v2_obj!(opm::FluxOpModel, sense = MOI.MIN_SENSE)
    v = get_jpvars(opm)
    JuMP.@objective(jump(opm), sense, v' * v)
    return opm
end
