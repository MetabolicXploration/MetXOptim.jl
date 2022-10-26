# -------------------------------------------------------------------
# extras interface
import MetXBase.get_extra
get_extra(m::FluxOpModel) = m.extras

# -------------------------------------------------------------------
# net interface
# NOTE: Do not interface with the net the data that will be in the constraints

# net data
metnet(opm::FluxOpModel)::Union{Nothing, MetNet} = get_extra(opm, :_net, nothing)
metnet!(opm::FluxOpModel, net::MetNet) = set_extra!(opm, :_net, net) 

import MetXBase.metabolites
metabolites(m::FluxOpModel, ider...) = metabolites(metnet(m), ider...)

import MetXBase.reactions
reactions(m::FluxOpModel, ider...) = reactions(metnet(m), ider...)

import MetXBase.genes
genes(m::FluxOpModel, ider...) = genes(metnet(m), ider...)

# contraints data
import MetXBase.lb
import MetXBase.lb!
lb(m::FluxOpModel) = JuMP.normalized_rhs.(get_lower_bound_cons(m))
lb(m::FluxOpModel, ridx) = lb(m)[rxnindex(m, ridx)]
function lb!(m::FluxOpModel, idxs, lb)
    upcons = get_lower_bound_cons(m)
    cidxs = rxnindex(m, idxs)
    up_con_rhs!(upcons, lb, cidxs)
    return m
end
lb!(m::FluxOpModel, lb) = lb!(m, 1:_length(m), lb)

# ub
import MetXBase.ub
import MetXBase.ub!
ub(m::FluxOpModel) = JuMP.normalized_rhs.(get_upper_bound_cons(m))
ub(m::FluxOpModel, ider) = ub(m)[rxnindex(m, ider)]
function ub!(m::FluxOpModel, idxs, ub)
    upcons = get_upper_bound_cons(m)
    cidxs = rxnindex(m, idxs)
    up_con_rhs!(upcons, ub, cidxs)
    return m
end
ub!(m::FluxOpModel, ub) = ub!(m, 1:_length(m), ub)

import MetXBase.bounds
import MetXBase.bounds!
bounds(m::FluxOpModel) = (lb(m), ub(m))
bounds(m::FluxOpModel, idx) = (lb(m, idx), ub(m, idx))
bounds!(m::FluxOpModel, idx, lb, ub) = (lb!(m, idx, lb); ub!(m, idx, ub); nothing)
function bounds!(m::FluxOpModel, idx; lb = nothing, ub = nothing) 
    isnothing(lb) || lb!(m, idx, lb)
    isnothing(ub) || ub!(m, idx, ub)
    return nothing
end

import MetXBase.balance
balance(m::FluxOpModel) = JuMP.normalized_rhs.(get_balance_cons(m))
balance(m::FluxOpModel, ider) = balance(m)[metindex(m, ider)]

import MetXBase.lin_objective
lin_objective(m::FluxOpModel, args...) = lin_objective(metnet(m), args...)

import MetXBase.lin_objective!
# change both, the JuMP objective and the cached net lin_objective vector
function lin_objective!(m::FluxOpModel, args...)
    net = metnet(m)
    lin_objective!(net, args...)
    set_linear_obj!(net, metnet(m))
    return m
end
    
# -------------------------------------------------------------------
# jump
export jump
jump(m::FluxOpModel) = m.jump
jump(m::FluxOpModel, k) = m.jump[k]

get_jpvars(m::FluxOpModel, ider) = get_jpvars(m)[rxnindex(m, ider)]

export solution
solution(m::FluxOpModel) = _solution(m)
solution(m::FluxOpModel, ider) = _solution(m, rxnindex(m, ider))


