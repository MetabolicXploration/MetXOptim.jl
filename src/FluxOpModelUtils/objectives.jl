## ------------------------------------------------------------------------------
const _LAST_OBJECTIVE_KEY = :_LAST_OBJECTIVE_KEY
const _CURR_OBJECTIVE_KEY = :_CURR_OBJECTIVE_KEY

export set_objective_function!
function set_objective_function!(objsetter!::Function, opm::FluxOpModel, newobjkey::Symbol)
    jpm = jump(opm)

    # current to last
    jpm[_LAST_OBJECTIVE_KEY] = jump(jpm, _CURR_OBJECTIVE_KEY, nothing)
    
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

function set_objective_function!(opm::FluxOpModel, newobjkey::Symbol)

    jpm = jump(opm)
    
    # current to last
    jpm[_LAST_OBJECTIVE_KEY] = jump(jpm, _CURR_OBJECTIVE_KEY, nothing)

    # get fun box
    fbox = jpm[newobjkey]
    
    # add to model
    set_objective_function(jpm, fbox.fun)
    set_objective_sense(jpm, fbox.sense)
    
    # curr data
    jpm[_CURR_OBJECTIVE_KEY] = fbox

    return opm
end

set_last_obj!(opm::FluxOpModel) = set_objective_function!(opm, _CURR_OBJECTIVE_KEY)

# execute f and ensure the model objective do not change.
# returns the value of f()
export keepobj!
function keepobj!(f::Function, opm::FluxOpModel)
    obj0 = nothing
    try
        jpm = jump(opm)
        obj0 = objective_function(jpm)
        return f()
    finally 
        if !isnothing(obj0) 
            set_objective_function(jpm, obj0)
            jpm[_CURR_OBJECTIVE_KEY] = obj0
        end
    end
end

## ------------------------------------------------------------------------------
# It MAXIMIZE c' * v[idx]
const _LIN_OBJECTIVE_KEY = :_LIN_OBJECTIVE_KEY
export set_linear_obj!
function set_linear_obj!(opm::FluxOpModel, idx, c)
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm, idx)
        @JuMP.objective(jpm, MOI.MAX_SENSE, c' * v)
    end
    return opm
end

# It MAXIMIZE c'*v
function set_linear_obj!(opm::FluxOpModel, c::AbstractVector)
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm)
        @JuMP.objective(jpm, MOI.MAX_SENSE, c' * v)
    end
    return opm
end

set_linear_obj!(opm::FluxOpModel, net::MetNet) = 
    set_linear_obj!(opm, lin_objective(net))

function set_linear_obj!(opm::FluxOpModel) 
    set_objective_function!(opm, _LIN_OBJECTIVE_KEY)
    return opm
end

## ------------------------------------------------------------------------------
const _V2_OBJECTIVE_KEY = :_V2_OBJECTIVE_KEY
export set_v2_obj!
function set_v2_obj!(opm::FluxOpModel, sense)
    set_objective_function!(opm, _V2_OBJECTIVE_KEY) do jpm
        v = get_jpvars(opm)
        JuMP.@objective(jpm, sense, v' * v)
    end
    return opm
end

function set_v2_obj!(opm::FluxOpModel) 
    set_objective_function!(opm, _V2_OBJECTIVE_KEY)
    return opm
end