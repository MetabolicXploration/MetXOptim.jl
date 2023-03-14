struct ObjFunBox
    name::Symbol
    fun::JuMP.AbstractJuMPScalar
    sense::JuMP.MOI.OptimizationSense
end

# Template  based builder
function ObjFunBox(template::ObjFunBox;
        name = template.name,
        fun =  template.fun, 
        sense = template.sense
    )

    return ObjFunBox(name, fun, sense)
end