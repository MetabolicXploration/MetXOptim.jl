## ------------------------------------------------------------------------------

# A model for optimizing over the space of flux configurations
struct FluxOpModel <: AbstractOpModel

    jump::JuMP.Model
    
    # extras
    extras::Dict{Any, Any}
end
export FluxOpModel

FluxOpModel(jpm::JuMP.Model) = FluxOpModel(jpm, Dict())

function FluxOpModel(jpm::JuMP.Model, net::MetNet;
        netfields = [:rxns, :c], # fields to chache
        netcopy = false # flag to make an internal copy of the net fields
    )

    # model
    opm = FluxOpModel(jpm)

    # cache net
    net0 = extract_fields(net, netfields)
    net0 = netcopy ? deepcopy(net0) : net0
    net1 = MetNet(; net0...)
    metnet!(opm, net1)

    return opm
end 

FluxOpModel(net::MetNet, jump_args...; kwargs...) = 
    FluxOpModel(JuMP.Model(jump_args...), net; kwargs...)

