# Jump methods and utils to be applicable directly over AbtractOpModels
# TODO: do more methods

# Common methods to work with jump models
jump(jpm::JuMP.Model) = jpm
jump(opm::AbstractOpModel) = error("Method jump(opm::$(typeof(opm))) not defined!")
jump(jpm::JuMP.Model, k) = jpm[k]
jump(opm::AbstractOpModel, k) = error("Method jump(opm::$(typeof(opm)), k) not defined!")

import JuMP.set_optimizer
set_optimizer(opm::AbstractOpModel, args...) = set_optimizer(jump(opm), args...)

import JuMP.set_silent
set_silent(opm::AbstractOpModel, args...) = set_silent(jump(opm), args...)

const _OPMODEL_VARIABLES_KEY = :op_vars
get_jpvars(jpm::JuMP.Model) = jpm[_OPMODEL_VARIABLES_KEY]
get_jpvars(opm::AbstractOpModel) = jump(opm, _OPMODEL_VARIABLES_KEY)
set_jpvars!(jpm::JuMP.Model, N::Integer) = 
    (jpm[_OPMODEL_VARIABLES_KEY] = @JuMP.variable(jpm, [1:N]); jpm)
set_jpvars!(opm::AbstractOpModel, N::Integer) = set_jpvars!(jump(opm), N)

import JuMP.normalized_rhs
normalized_rhs(opm::AbstractOpModel, cons_key::Symbol) = JuMP.normalized_rhs.(jump(opm, cons_key))

function up_con_rhs!(
        opm::AbstractOpModel, cons_key::Symbol, 
        vals::Vector, cidxs
    )
    @assert length(vals) == length(cidxs)
    cons = jump(opm, cons_key)
    for (ci, val) in zip(cidxs, vals)
        JuMP.set_normalized_rhs(cons[ci], val)
    end
    return opm
end

function up_con_rhs!(
        opm::AbstractOpModel, cons_key::Symbol, 
        val::Number, cidx::Integer
    )
    cons = jump(opm, cons_key)
    JuMP.set_normalized_rhs(cons[cidx], val)
    return opm
end

import JuMP.delete!
function delete!(opm::AbstractOpModel, sym::Symbol)
    jpm = jump(opm)
    delete!(jpm, jpm[sym])
    JuMP.unregister(jpm, sym)
    return opm
end

# TODO: test this
function set_start_value(opm::AbstractOpModel, vals)
    xs = get_jpvars(opm)
    for (x, val) in zip(xs, vals)
        JuMP.set_start_value(x, val)
    end
    return lp_model
end

import JuMP.haskey
haskey(opm::AbstractOpModel, key) = haskey(jump(opm), key)