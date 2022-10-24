## ------------------------------------------------------------------
function FBAFluxOpModel(net::MetNet, solver)

    opm = FluxOpModel(net, solver)
    JuMP.set_silent(opm)

    set_jpvars!(opm, rxns_count(net))
    
    set_lower_bound_cons!(opm, lb(net))
    set_upper_bound_cons!(opm, ub(net))
    set_balance_cons!(opm, stoi(net), balance(net))
    
    return opm
end
# build_lp_model(net::MetNet; solver = Clp.Optimizer) = build_lp_model(net, solver)
