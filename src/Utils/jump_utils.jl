function _delete!(jpm::JuMP.Model, con)
    try
        JuMP.delete(jpm, con)
        catch err; (err isa JuMP.MOI.InvalidIndex) || rethrow(err)
    end
    return jpm
end
_delete!(jpm::JuMP.Model, sym::Symbol) = (JuMP.haskey(jpm, sym) && _delete!(jpm, jpm[sym]); JuMP.unregister(jpm, sym))
_delete!(jpm::AbstractOpModel, con) = _delete!(jump(jpm), con)
