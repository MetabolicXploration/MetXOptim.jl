## ------------------------------------------------------------------
export r2_fba
function r2_fba!(opm::FluxOpModel; r2_sense = MIN_SENSE)

    # opt previous solution
    optimize!(opm)

    # fix objval
    objval = objective_value(opm)
    set_obj_balance_cons!(opm, objval)
    
    # Optimize v^2
    set_v2_obj!(opm, r2_sense)
    optimize!(opm)

    return opm
end

function r2_fba(opm::FluxOpModel; r2_sense = MIN_SENSE) 
    keepobj!(() -> r2_fba!(opm; r2_sense), opm)
    del_obj_balance_cons!(opm)
    return opm
end

# TODO: make a r2_fba version
# del_obj_balance_cons!(opm)
