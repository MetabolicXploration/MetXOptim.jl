export R2FBAFluxOpModel
function R2FBAFluxOpModel(
        net::MetNet, solver; 
        r2_sense = MIN_SENSE,
        netfields = [:rxns, :c], # fields to chache
        netcopy = false # flag to make an internal copy of the net fields
    )

    opm = FBAFluxOpModel(net, solver; netfields, netcopy)
    set_v2_obj!(opm, r2_sense) # registry r2_obj

    return opm
end

## ------------------------------------------------------------------
## ------------------------------------------------------------------
# TODO: Redo this as a obj stack execution infrastructure 
export r2_fba!
function r2_fba!(opm::FluxOpModel; 
        clear_bal_cons = true
    )

    # fba
    set_linear_obj!(opm)
    optimize!(opm)
    # @show objective_value(opm)

    # fix objval
    objval = objective_value(opm)
    set_lin_obj_balance_cons!(opm, objval)
    
    # Optimize v^2
    set_v2_obj!(opm)
    optimize!(opm)
    clear_bal_cons && del_obj_balance_cons!(opm)
    # @show objective_value(opm)

    return opm
end

function r2_fba!(opm::FluxOpModel, r2_sense; 
        clear_bal_cons = true
    )
    set_v2_obj!(opm, r2_sense)
    r2_fba!(opm; clear_bal_cons)
    return opm
end

r2_fba!(opm::FluxOpModel, ::Nothing; kwargs...) = r2_fba!(opm; kwargs...)

## ------------------------------------------------------------------
# AbstractMetNet
export r2_fba
function r2_fba(net::AbstractMetNet, solver; 
        r2_sense = MIN_SENSE, opmodel_kwargs...
    ) 
    net = metnet(net)
    opm = R2FBAFluxOpModel(net, solver; r2_sense, opmodel_kwargs...)
    return opm
end
