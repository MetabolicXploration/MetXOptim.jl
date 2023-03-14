# -------------------------------------------------------------------
# Fundamentals

import MetXBase.colids
colids(opm::FluxOpModel) = extras(opm, :colids)::Union{Nothing, Vector{String}}
import MetXBase.rowids
rowids(opm::FluxOpModel) = extras(opm, :rowids)::Union{Nothing, Vector{String}}

# -------------------------------------------------------------------
# Utils
# NOTE: Do not interface with the lep the data that will be in the constraints

# contraints data
import MetXGEMs.lb
import MetXGEMs.lb!
lb(opm::FluxOpModel) = JuMP.normalized_rhs.(get_lower_bound_cons(opm))::Vector{Float64}
_lb(opm::FluxOpModel, ridx::Int) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Float64
_lb(opm::FluxOpModel, ridx) = JuMP.normalized_rhs.(get_lower_bound_cons(opm)[ridx])::Vector{Float64}
lb(opm::FluxOpModel, ridx) = _lb(opm, colindex(opm, ridx))
function lb!(opm::FluxOpModel, idxs, lb)
    upcons = get_lower_bound_cons(opm)
    cidxs = colindex(opm, idxs)
    up_con_rhs!(upcons, lb, cidxs)
    return opm
end
lb!(opm::FluxOpModel, lb) = lb!(opm, 1:length(get_lower_bound_cons(opm)), lb)

# ub
import MetXGEMs.ub
import MetXGEMs.ub!
ub(opm::FluxOpModel) = JuMP.normalized_rhs.(get_upper_bound_cons(opm))::Vector{Float64}
_ub(opm::FluxOpModel, idx::Int) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Float64
_ub(opm::FluxOpModel, idx) = JuMP.normalized_rhs.(get_upper_bound_cons(opm)[idx])::Vector{Float64}
ub(opm::FluxOpModel, ider) = _ub(opm, colindex(opm, ider))
function ub!(opm::FluxOpModel, idxs, ub)
    upcons = get_upper_bound_cons(opm)
    cidxs = colindex(opm, idxs)
    up_con_rhs!(upcons, ub, cidxs)
    return opm
end
ub!(opm::FluxOpModel, ub) = ub!(opm, 1:length(get_upper_bound_cons(opm)), ub)

import MetXGEMs.bounds
import MetXGEMs.bounds!
bounds(opm::FluxOpModel) = (lb(opm), ub(opm))
bounds(opm::FluxOpModel, idx) = (lb(opm, idx), ub(opm, idx))
bounds!(opm::FluxOpModel, idx, lb, ub) = (lb!(opm, idx, lb); ub!(opm, idx, ub); nothing)
function bounds!(opm::FluxOpModel, idx; lb = nothing, ub = nothing) 
    isnothing(lb) || lb!(opm, idx, lb)
    isnothing(ub) || ub!(opm, idx, ub)
    return nothing
end

import MetXGEMs.balance
balance(opm::FluxOpModel) = JuMP.normalized_rhs.(get_balance_cons(opm))::Vector{Float64}
balance(opm::FluxOpModel, ider) = balance(opm)[rowindex(opm, ider)]
