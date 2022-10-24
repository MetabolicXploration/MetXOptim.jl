## ------------------------------------------------------------------------------
# A model for optimizing over the space of flux configurations
struct FluxOpModel <: AbstractOpModel

    jump::JuMP.Model

    # meta
    mets::Union{Nothing, Array{String,1}}                          # metabolites short-name M elements 
    rxns::Union{Nothing, Array{String,1}}                          # reactions short-name N elements
    genes::Union{Nothing, Array{String,1}}                         # reactions short-name N elements
    
    # extras
    extras::Dict{Any, Any}
end
export FluxOpModel

FluxOpModel(jpm::JuMP.Model, net::MetXBase.MetNet) = 
    FluxOpModel(jpm, net.mets, net.rxns, net.genes, Dict())

FluxOpModel(net::MetXBase.MetNet, jump_args...) = 
    FluxOpModel(JuMP.Model(jump_args...), net.mets, net.rxns, net.genes, Dict())

FluxOpModel(jpm::JuMP.Model) = 
    FluxOpModel(jpm, nothing, nothing, nothing, Dict())

