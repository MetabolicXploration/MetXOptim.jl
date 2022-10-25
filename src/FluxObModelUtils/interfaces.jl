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
# function lb!(opm::FluxOpModel, cidxs, lb)
#     jpm = jump(opm)
#     if haskey(jpm, _LB_CON_KEY)
#         up_con_rhs!(jpm, _LB_CON_KEY, lb, cidxs)
#     else
#         x = jp_vars(opm)
#         jpm[_LB_CON_KEY] = @JuMP.constraint(jpm, x .>= lb, base_name = string(_LB_CON_KEY))
#     end
#     return opm
# end
# lb!(m::FluxOpModel, lb) = lb!(m, :, m)

# ub
import MetXBase.ub
import MetXBase.ub!
ub(m::FluxOpModel) = JuMP.normalized_rhs.(get_upper_bound_cons(m))
ub(m::FluxOpModel, ider) = ub(m)[rxnindex(m, ider)]
# function ub!(m::FluxOpModel, cidxs, ub)
#     if haskey(m, _UB_CON_KEY)
#         up_con_rhs!(m, _UB_CON_KEY, ub, cidxs)
#     else
#         x = _get_vars(m)
#         m[_UB_CON_KEY] = @JuMP.constraint(m, x .<= ub, base_name = string(_UB_CON_KEY))
#     end
#     return m
# end
# ub!(m::FluxOpModel, ub) = ub!(m, 1:_length(m), ub)

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
    
# -------------------------------------------------------------------
# jump
export jump
jump(m::FluxOpModel) = m.jump
jump(m::FluxOpModel, k) = m.jump[k]

export solution
solution(m::FluxOpModel, ider) = solution(m)[rxnindex(m, ider)]
