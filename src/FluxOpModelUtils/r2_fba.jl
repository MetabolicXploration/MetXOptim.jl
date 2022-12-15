## ------------------------------------------------------------------
# TODO: rethink Optim models interface
# what is expected from the model before the firts optimize!
# TODO: make obj functions stack interface

# TODO: Test this
export r2_fba
function _r2_fba!(opm::FluxOpModel; r2_sense = MIN_SENSE)

    # opt previous solution
    optimize!(opm)
    @show objective_value(opm)

    # fix objval
    objval = objective_value(opm)
    set_obj_balance_cons!(opm, objval)
    
    # Optimize v^2
    set_v2_obj!(opm, r2_sense)
    optimize!(opm)
    @show objective_value(opm)

    return opm
end

function _r2_fba(opm::FluxOpModel; r2_sense = MIN_SENSE) 
    keepobj!(() -> _r2_fba!(opm; r2_sense), opm)
    del_obj_balance_cons!(opm)
    return opm
end

## ------------------------------------------------------------------
# AbstractMetNet
function r2_fba(net::AbstractMetNet, solver; 
        r2_sense = MIN_SENSE, opmodel_kwargs...
    ) 
    opm = FBAFluxOpModel(metnet(net), solver; opmodel_kwargs...)
    _r2_fba!(opm; r2_sense)
    return opm
end
