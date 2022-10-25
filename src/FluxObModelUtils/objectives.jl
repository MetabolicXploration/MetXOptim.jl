# It MAXIMIZE c'*v
function set_linear_obj!(opm::FluxOpModel, c::AbstractVector)
    v = get_jpvars(opm)
    @JuMP.objective(jump(opm), MOI.MAX_SENSE, c' * v)
    return opm
end

set_linear_obj!(opm::FluxOpModel, net::MetNet) = 
    set_linear_obj!(opm::FluxOpModel, lin_objective(net))