const _OPMODEL_VARIABLES_KEY = :op_vars
get_jpvars(jpm::JuMP.Model) = jpm[_OPMODEL_VARIABLES_KEY]::Vector{VariableRef}
get_jpvars(opm::AbstractOpModel) = get_jpvars(jump(opm))
set_jpvars!(jpm::JuMP.Model, N::Integer) = 
    (jpm[_OPMODEL_VARIABLES_KEY] = @JuMP.variable(jpm, [1:N]); jpm)
set_jpvars!(opm::AbstractOpModel, N::Integer) = set_jpvars!(jump(opm), N)

# TODO: Fix dispatch issue (try `const solution = _solution` and see)
# TODO: Im fixing the eltype to Float64, generalize it
_solution(opm::AbstractOpModel) = jump(opm, _OPM_SOLUTION_KEY)::Vector{Float64}
_solution(opm::AbstractOpModel, idxs) = getindex(jump(opm, _OPM_SOLUTION_KEY)::Vector{Float64}, idxs)

const _OPM_SOLUTION_KEY = :_OPM_SOLUTION_KEY
function _solution!(jpm::JuMP.Model) 
    sol = JuMP.value.(get_jpvars(jpm))
    jpm[_OPM_SOLUTION_KEY] = sol
    return sol
end

import Base.length
length(opm::AbstractOpModel) = length(get_jpvars(opm))

export up_con_rhs!
function up_con_rhs!(
        cons::Vector{<:ConstraintRef}, vals, cidxs
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
export delete!
function delete!(opm::AbstractOpModel, sym::Symbol)
    jpm = jump(opm)
    delete!(jpm, jpm[sym])
    JuMP.unregister(jpm, sym)
    return opm
end

# TODO: finish/test this
import JuMP.set_start_value
export set_start_value
function set_start_value(opm::AbstractOpModel, vals)
    xs = get_jpvars(opm)
    for (x, val) in zip(xs, vals)
        JuMP.set_start_value(x, val)
    end
    return lp_model
end