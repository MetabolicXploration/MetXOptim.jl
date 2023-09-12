# -------------------------------------------------------------------
# Fundamentals

import MetXBase.colids
colids(opm::OpModel) = extras(opm, :colids)::Union{Nothing, Vector{String}}
import MetXBase.rowids
rowids(opm::OpModel) = extras(opm, :rowids)::Union{Nothing, Vector{String}}

# -------------------------------------------------------------------
# Utils
# NOTE: Do not interface with the lep the data that will be in the constraints

# contraints data
import MetXBase.lb
import MetXBase.lb!
lb(opm::OpModel) = JuMP.normalized_rhs.(get_lower_bound_cons(opm))::Vector{Float64}
_lb(opm::OpModel, ridx::Integer) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Float64
_lb(opm::OpModel, ridx) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Vector{Float64}
lb(opm::OpModel, ridx) = _lb(opm, colindex(opm, ridx))
function lb!(opm::OpModel, idxs, lb)
    upcons = get_lower_bound_cons(opm)
    cidxs = colindex(opm, idxs)
    up_con_rhs!(upcons, lb, cidxs)
    return opm
end
lb!(opm::OpModel, lb) = lb!(opm, 1:length(get_lower_bound_cons(opm)), lb)

# ub
import MetXBase.ub
import MetXBase.ub!
ub(opm::OpModel) = JuMP.normalized_rhs.(get_upper_bound_cons(opm))::Vector{Float64}
_ub(opm::OpModel, idx::Integer) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Float64
_ub(opm::OpModel, idx) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Vector{Float64}
ub(opm::OpModel, ider) = _ub(opm, colindex(opm, ider))
function ub!(opm::OpModel, idxs, ub)
    upcons = get_upper_bound_cons(opm)
    cidxs = colindex(opm, idxs)
    up_con_rhs!(upcons, ub, cidxs)
    return opm
end
ub!(opm::OpModel, ub) = ub!(opm, 1:length(get_upper_bound_cons(opm)), ub)

import MetXBase.bounds
import MetXBase.bounds!
bounds(opm::OpModel) = (lb(opm), ub(opm))
bounds(opm::OpModel, idx) = (lb(opm, idx), ub(opm, idx))
bounds!(opm::OpModel, idx, lb, ub) = (lb!(opm, idx, lb); ub!(opm, idx, ub); nothing)
function bounds!(opm::OpModel, idx; lb = nothing, ub = nothing) 
    isnothing(lb) || lb!(opm, idx, lb)
    isnothing(ub) || ub!(opm, idx, ub)
    return nothing
end

import MetXBase.balance
balance(opm::OpModel) = JuMP.normalized_rhs.(get_balance_cons(opm))::Vector{Float64}
balance(opm::OpModel, ider) = balance(opm)[rowindex(opm, ider)]
