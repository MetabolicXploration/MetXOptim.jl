## ------------------------------------------------------------------
# Just a wrapper that add all the basic constraints of FBA
export FBAFluxOpModel
function FBAFluxOpModel(
        S::AbstractMatrix, b::AbstractVector, 
        lb::AbstractVector, ub::AbstractVector, 
        c::AbstractVector, 
        jump_args...
    )

    opm = FluxOpModel(JuMP.Model(jump_args...))
    JuMP.set_silent(opm)

    set_jpvars!(opm, size(S, 2))
    
    set_lower_bound_cons!(opm, lb)
    set_upper_bound_cons!(opm, ub)
    set_balance_cons!(opm, S, b)

    set_linear_obj!(opm, c)
    
    return opm
end

## ------------------------------------------------------------------
function FBAFluxOpModel(
        net::MetNet, jump_args...; 
        netfields = [:rxns, :c], # fields to chache
        netcopy = false # flag to make an internal copy of the net fields
    )

    opm = FBAFluxOpModel(
        net.S, net.b, 
        net.lb, net.ub, net.c, 
        jump_args...
    )

    # cache net
    net0 = extract_fields(net, netfields)
    net0 = netcopy ? deepcopy(net0) : net0
    net1 = MetNet(; net0...)
    metnet!(opm, net1)
    
    return opm
end

## ------------------------------------------------------------------
# fba
export fba, fba!
function fba!(opm::FluxOpModel) 
    set_linear_obj!(opm, balance(opm))
    optimize!(opm) 
    return opm
end

## ------------------------------------------------------------------
# AbstractMetNet
fba(net::AbstractMetNet, jump_args...; opmodel_kwargs...) = 
    fba!(FBAFluxOpModel(metnet(net), jump_args...; opmodel_kwargs...))
