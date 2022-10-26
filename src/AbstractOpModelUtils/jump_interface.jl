# Jump methods and utils to be applicable directly over AbtractOpModels
# TODO: do more methods

# Common methods to work with jump models
export jump
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

# TODO: Fix dispatch issue (try `const solution = _solution` and see)
_solution(opm::AbstractOpModel) = JuMP.value.(get_jpvars(opm))
_solution(opm::AbstractOpModel, idx::Int) = JuMP.value(get_jpvars(opm)[idx])
_solution(opm::AbstractOpModel, idxs) = JuMP.value.(get_jpvars(opm)[idxs])

import JuMP.termination_status
termination_status(opm::AbstractOpModel) = JuMP.termination_status(jump(opm))

import JuMP.normalized_rhs
normalized_rhs(opm::AbstractOpModel, cons_key::Symbol) = JuMP.normalized_rhs.(jump(opm, cons_key))

function up_con_rhs!(
        cons::Vector{<:ConstraintRef}, vals::Vector, cidxs
    )
    @assert length(vals) == length(cidxs)
    for (ci, val) in zip(cidxs, vals)
        JuMP.set_normalized_rhs(cons[ci], val)
    end
    return cons
end

function up_con_rhs!(
        cons::Vector{<:ConstraintRef}, val::Number, cidxs
    )
    for ci in cidxs
        JuMP.set_normalized_rhs(cons[ci], val)
    end
    return cons
end

up_con_rhs!(opm::AbstractOpModel, 
    cons_key::Symbol, vals, cidxs
) = up_con_rhs!(jump(opm, cons_key), vals, cidxs)

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
haskey(opm::AbstractOpModel, key) = JuMP.haskey(jump(opm), key)

import JuMP.optimize!
optimize!(opm::AbstractOpModel; kwargs...) = JuMP.optimize!(jump(opm); kwargs...)