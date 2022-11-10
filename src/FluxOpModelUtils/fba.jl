## ------------------------------------------------------------------
# Just a wrapper that add all the basic cosntraints of FBA
export FBAFluxOpModel
function FBAFluxOpModel(net::MetNet, jump_args...; 
        opmodel_kwargs...
    )

    opm = FluxOpModel(net, jump_args...; opmodel_kwargs...)
    JuMP.set_silent(opm)

    set_jpvars!(opm, rxns_count(net))
    
    set_lower_bound_cons!(opm, lb(net))
    set_upper_bound_cons!(opm, ub(net))
    set_balance_cons!(opm, stoi(net), balance(net))

    set_linear_obj!(opm, net)
    
    return opm
end

## ------------------------------------------------------------------
# fba
export fba, fba!
fba!(opm::FluxOpModel) = (optimize!(opm); opm)
fba(net::MetNet, jump_args...; opmodel_kwargs...) = 
    fba!(FBAFluxOpModel(net, jump_args...; opmodel_kwargs...))

## ------------------------------------------------------------------
# fba_stack
