struct ObjFunBox
    name::Symbol
    fun::JuMP.AbstractJuMPScalar
    sense::JuMP.MOI.OptimizationSense
    extras::Dict{Symbol, Any}
    
    function ObjFunBox(name, fun, sense; extras = Dict{Symbol, Any}())
        new(name, fun, sense, extras)
    end
end

# Template  based builder
function ObjFunBox(template::ObjFunBox;
        name = template.name,
        fun =  template.fun, 
        sense = template.sense,
        extras = template.extras
    )

    return ObjFunBox(name, fun, sense; extras)
end