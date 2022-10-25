## ------------------------------------------------------------------------------

# A model for optimizing over the space of flux configurations
struct FluxOpModel <: AbstractOpModel

    jump::JuMP.Model

    # # meta
    # mets::Union{Nothing, Array{String,1}}                          # metabolites short-name M elements 
    # rxns::Union{Nothing, Array{String,1}}                          # reactions short-name N elements
    # genes::Union{Nothing, Array{String,1}}                         # reactions short-name N elements
    
    # extras
    extras::Dict{Any, Any}
end
export FluxOpModel

FluxOpModel(jpm::JuMP.Model) = 
    FluxOpModel(jpm, Dict())

function FluxOpModel(jpm::JuMP.Model, net::MetNet;
        netfields = [:rxns]
    )
    opm = FluxOpModel(jpm)

    # cache net
    net1 = MetNet(; extract_fields(net, netfields)...)
    metnet!(opm, net1)

    return opm
end 

FluxOpModel(net::MetNet, jump_args...; kwargs...) = 
    FluxOpModel(JuMP.Model(jump_args...), net; kwargs...)

