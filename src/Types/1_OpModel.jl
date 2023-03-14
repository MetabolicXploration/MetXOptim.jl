## ------------------------------------------------------------------------------
# TODO: Im fixing the eltype of OpModel to Float64, make it a parameter

# Just a wrapper around a JuMP model
struct OpModel <: AbstractOpModel

    jump::JuMP.Model
    
    # extras
    extras::Dict{Any, Any}
end
export OpModel

OpModel(jpm::JuMP.Model) = OpModel(jpm, Dict())
