struct ObjFunBox
    name::Symbol
    fun::JuMP.AbstractJuMPScalar
    sense::JuMP.MOI.OptimizationSense
end