# -------------------------------------------------------------------
# extras interface
import MetXBase.extras
extras(opm::FluxOpModel)::Dict = opm.extras

# -------------------------------------------------------------------
# config interface
@extras_dict_interface FluxOpModel config

# -------------------------------------------------------------------
# net interface
# NOTE: Do not interface with the net the data that will be in the constraints

# net data
@extras_val_interface FluxOpModel metnet MetNet

import MetXBase.metabolites
metabolites(opm::FluxOpModel, ider...) = metabolites(metnet(opm), ider...)

import MetXBase.reactions
reactions(opm::FluxOpModel, ider...) = reactions(metnet(opm), ider...)

import MetXBase.genes
genes(opm::FluxOpModel, ider...) = genes(metnet(opm), ider...)

# contraints data
import MetXBase.lb
import MetXBase.lb!
lb(opm::FluxOpModel) = JuMP.normalized_rhs.(get_lower_bound_cons(opm))::Vector{Float64}
_lb(opm::FluxOpModel, ridx::Int) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Float64
_lb(opm::FluxOpModel, ridx) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Vector{Float64}
lb(opm::FluxOpModel, ridx) = _lb(opm, rxnindex(opm, ridx))
function lb!(opm::FluxOpModel, idxs, lb)
    upcons = get_lower_bound_cons(opm)
    cidxs = rxnindex(opm, idxs)
    up_con_rhs!(upcons, lb, cidxs)
    return opm
end
lb!(opm::FluxOpModel, lb) = lb!(opm, 1:_length(opm), lb)

# ub
import MetXBase.ub
import MetXBase.ub!
ub(opm::FluxOpModel) = JuMP.normalized_rhs.(get_upper_bound_cons(opm))::Vector{Float64}
_ub(opm::FluxOpModel, idx::Int) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Float64
_ub(opm::FluxOpModel, idx) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Vector{Float64}
ub(opm::FluxOpModel, ider) = _ub(opm, rxnindex(opm, ider))
function ub!(opm::FluxOpModel, idxs, ub)
    upcons = get_upper_bound_cons(opm)
    cidxs = rxnindex(opm, idxs)
    up_con_rhs!(upcons, ub, cidxs)
    return opm
end
ub!(opm::FluxOpModel, ub) = ub!(opm, 1:_length(opm), ub)

import MetXBase.bounds
import MetXBase.bounds!
bounds(opm::FluxOpModel) = (lb(opm), ub(opm))
bounds(opm::FluxOpModel, idx) = (lb(opm, idx), ub(opm, idx))
bounds!(opm::FluxOpModel, idx, lb, ub) = (lb!(opm, idx, lb); ub!(opm, idx, ub); nothing)
function bounds!(opm::FluxOpModel, idx; lb = nothing, ub = nothing) 
    isnothing(lb) || lb!(opm, idx, lb)
    isnothing(ub) || ub!(opm, idx, ub)
    return nothing
end

import MetXBase.balance
balance(opm::FluxOpModel) = JuMP.normalized_rhs.(get_balance_cons(opm))::Vector{Float64}
balance(opm::FluxOpModel, ider) = balance(opm)[metindex(opm, ider)]

import MetXBase.lin_objective
lin_objective(opm::FluxOpModel, args...) = lin_objective(metnet(opm), args...)::Vector{Float64}

import MetXBase.lin_objective!
# change both, the JuMP objective and the cached net lin_objective vector
function lin_objective!(opm::FluxOpModel, args...)
    net = metnet(opm)
    lin_objective!(net, args...)
    set_linear_obj!(opm, metnet(opm))
    return opm
end
    
# -------------------------------------------------------------------
# jump
export jump
jump(opm::FluxOpModel) = opm.jump
jump(opm::FluxOpModel, k) = opm.jump[k]

get_jpvars(opm::FluxOpModel, ider) = get_jpvars(opm)[rxnindex(opm, ider)]

export solution
solution(opm::FluxOpModel) = _solution(opm)
solution(opm::FluxOpModel, ider) = _solution(opm, rxnindex(opm, ider))

import JuMP.objective_value
export objective_value
objective_value(opm::FluxOpModel) = objective_value(jump(opm))

import JuMP.objective_function
export objective_function
objective_function(opm::FluxOpModel) = objective_function(jump(opm))

import JuMP.set_objective_function
export set_objective_function
set_objective_function(opm::FluxOpModel, f) = set_objective_function(jump(opm), f)

import JuMP.set_objective_sense
export set_objective_sense
set_objective_sense(opm::FluxOpModel, sense) = set_objective_sense(jump(opm), sense)

import JuMP.set_objective
export set_objective
set_objective(opm::FluxOpModel, sense, func) = set_objective(jump(opm), sense, func)
