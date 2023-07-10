function R2FBAOpModel(
        lep::LEPModel, solver;
        r2_sense = MIN_SENSE,
        add_extras!::Function = (opm) -> nothing
    )

    opm = FBAOpModel(lep, solver; add_extras!)
    set_v2_obj!(opm, r2_sense) # register r2_obj

    return opm
end

## ------------------------------------------------------------------
## ------------------------------------------------------------------
# TODO: Redo this as a obj stack execution infrastructure 
function r2_fba!(opm::OpModel; 
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

function r2_fba!(opm::OpModel, r2_sense; 
        clear_bal_cons = true
    )
    set_v2_obj!(opm, r2_sense)
    r2_fba!(opm; clear_bal_cons)
    return opm
end

r2_fba!(opm::OpModel, ::Nothing; kwargs...) = r2_fba!(opm; kwargs...)

## ------------------------------------------------------------------
# LEP Interface
function r2_fba(model, solver; 
        r2_sense = MIN_SENSE,
        add_extras!::Function = (opm) -> nothing,
        clear_bal_cons = true
    ) 
    lep = lepmodel(model)
    opm = R2FBAOpModel(lep, solver; r2_sense, add_extras!)
    return r2_fba!(opm, r2_sense; clear_bal_cons)
end
