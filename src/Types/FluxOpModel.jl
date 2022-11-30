## ------------------------------------------------------------------------------
# TODO: Im fixing the eltype of FluxOpModel to Float64, make it a parameter

# A model for optimizing over the space of flux configurations
struct FluxOpModel <: AbstractOpModel

    jump::JuMP.Model
    
    # extras
    extras::Dict{Any, Any}
end
export FluxOpModel

FluxOpModel(jpm::JuMP.Model) = FluxOpModel(jpm, Dict())
