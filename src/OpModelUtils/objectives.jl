## ------------------------------------------------------------------------------
const _LAST_OBJECTIVE_KEY = :_LAST_OBJECTIVE_KEY
const _CURR_OBJECTIVE_KEY = :_CURR_OBJECTIVE_KEY

## ------------------------------------------------------------------------------
import JuMP.objective_function
objective_function(opm::OpModel) = jump(opm, _CURR_OBJECTIVE_KEY, nothing)

import JuMP.objective_sense
function objective_sense(opm::OpModel) 
    fbox = jump(opm, _CURR_OBJECTIVE_KEY, nothing)
    isnothing(fbox) ? nothing : fbox.sense
end

## ------------------------------------------------------------------------------
function set_objective_function!(objsetter!::Function, opm::OpModel, newobjkey::Symbol)
    jpm = jump(opm)

    # current to last
    jpm[_LAST_OBJECTIVE_KEY] = objective_function(opm)
    # set fun on model
    objsetter!(jpm)

    # retrive the function data
    jpfun = objective_function(jpm)
    sense = objective_sense(jpm)
    fbox = ObjFunBox(newobjkey, jpfun, sense)
    
    # register the data
    jpm[newobjkey] = fbox
    
    # curr data
    jpm[_CURR_OBJECTIVE_KEY] = fbox

    return opm
end

function set_objective_function!(opm::OpModel, fbox::ObjFunBox)
    
    jpm = jump(opm)

    # current to last
    jpm[_LAST_OBJECTIVE_KEY] = objective_function(opm)

    # add to model
    set_objective_function(jpm, fbox.fun)
    set_objective_sense(jpm, fbox.sense)
    
    # curr data
    jpm[_CURR_OBJECTIVE_KEY] = fbox

    return opm
end

function set_objective_function!(opm::OpModel, newobjkey::Symbol)

    jpm = jump(opm)
    
    # current to last
    jpm[_LAST_OBJECTIVE_KEY] = objective_function(opm)
    
    set_objective_function!(opm, jpm[newobjkey])
end

set_last_obj!(opm::OpModel) = set_objective_function!(opm, _CURR_OBJECTIVE_KEY)

## ------------------------------------------------------------------------------
function set_objective_sense!(opm::OpModel, sense)
    currfbox = objective_function(opm)
    isnothing(currfbox) && error("No objective set!")
    newfbox = ObjFunBox(currfbox; sense)
    set_objective_function!(opm, newfbox)
    return opm
end

## ------------------------------------------------------------------------------
# execute f and ensure the model objective do not change.
# returns the value of f()
function keepobj(f::Function, opm::OpModel)
    fbox = nothing
    try
        fbox = jump(opm, _CURR_OBJECTIVE_KEY, nothing)
        return f()
    finally 
        if !isnothing(fbox) 
            set_objective_function!(opm, fbox)
        end
    end
    return nothing
end

## ------------------------------------------------------------------------------
# Standard linear objective

# TODO: rename/redo this. It is hard to use

# It MAXIMIZE c' * v[idx]
const _LIN_OBJECTIVE_KEY = :_LIN_OBJECTIVE_KEY
function _set_linear_obj!(opm::OpModel, idx, c)
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm, idx)
        @JuMP.objective(jpm, MOI.MAX_SENSE, c' * v)
    end
    return opm
end
set_linear_obj!(opm::OpModel, idx, c::Real) = _set_linear_obj!(opm, idx, c)
set_linear_obj!(opm::OpModel, idx, c::AbstractVector) = _set_linear_obj!(opm, idx, c)

function set_linear_obj!(opm::OpModel, idx, sense::MOI.OptimizationSense)
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm, idx)
        @JuMP.objective(jpm, sense, sum(v))
    end
    return opm
end

# It MAXIMIZE c'*v
function set_linear_obj!(opm::OpModel, c::AbstractVector)
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm)
        @JuMP.objective(jpm, MOI.MAX_SENSE, c' * v)
    end
    return opm
end

set_linear_obj!(opm::OpModel, lep::LEPModel) = 
    set_linear_obj!(opm, linear_weights(lep))

# Set the last linear objective
set_linear_obj!(opm::OpModel) =
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY)

## ------------------------------------------------------------------------------
# Standard quad objective
const _V2_OBJECTIVE_KEY = :_V2_OBJECTIVE_KEY

# TODO: rename to quad obj

function set_v2_obj!(opm::OpModel, sense::MOI.OptimizationSense)
    set_objective_function!(opm, _V2_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm)
        JuMP.@objective(jpm, sense, v' * v)
    end
    return opm
end

function set_v2_obj!(opm::OpModel, idxs, sense::MOI.OptimizationSense)
    set_objective_function!(opm, _V2_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm, idxs)
        JuMP.@objective(jpm, sense, v' * v)
    end
    return opm
end

function set_v2_obj!(opm::OpModel, C::AbstractMatrix, sense::MOI.OptimizationSense)
    set_objective_function!(opm, _V2_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm)
        JuMP.@objective(jpm, sense, v' * C * v)
    end
    return opm
end

# Set the last quadratic objective
function set_v2_obj!(opm::OpModel) 
    set_objective_function!(opm, _V2_OBJECTIVE_KEY)
    return opm
end

# LEP
set_v2_obj!(opm::OpModel, lep::LEPModel) = 
    set_v2_obj!(opm::OpModel, quad_weights(lep), MOI.MAX_SENSE)