# execute f and ensure the model objective do not change.
# returns the value of f()
export keepobj!
function keepobj!(f::Function, opm::FluxOpModel)
    obj0 = nothing
    try
        obj0 = objective_function(opm)
        return f()
        finally; isnothing(obj0) || set_objective_function(opm, obj0)
    end
end