## ------------------------------------------------------------------------------
# Contraints KEYS
const _BALANCE_CON_KEY = :balance_con
const _LOWER_BOUND_CON_KEY = :lb_con
const _UPPER_BOUND_CON_KEY = :ub_con

## ------------------------------------------------------------------------------
# balance constraints
function set_balance_cons!(fm::FluxOpModel, S::AbstractMatrix, b::AbstractVector)
    jpm = jump(fm)
    haskey(jpm, _BALANCE_CON_KEY) && delete!(jpm, _BALANCE_CON_KEY)
    v = get_jpvars(jpm)
    jpm[_BALANCE_CON_KEY] = @JuMP.constraint(jpm, 
        S * v .- b .== zero(eltype(b)),
        base_name = string(_BALANCE_CON_KEY)
    )
    return fm
end
get_balance_cons(fm::FluxOpModel) = jump(fm, _BALANCE_CON_KEY)

## ------------------------------------------------------------------------------
# bounds constraints
function set_lower_bound_cons!(fm::FluxOpModel, lb::AbstractVector)
    jpm = jump(fm)
    haskey(jpm, _LOWER_BOUND_CON_KEY) && delete!(jpm, _LOWER_BOUND_CON_KEY)
    v = get_jpvars(jpm)
    jpm[_LOWER_BOUND_CON_KEY] = @JuMP.constraint(jpm, 
        v .>= lb, 
        base_name = string(_LOWER_BOUND_CON_KEY)
    )
    return fm
end
get_lower_bound_cons(fm::FluxOpModel) = jump(fm, _LOWER_BOUND_CON_KEY)

function set_upper_bound_cons!(fm::FluxOpModel, ub::AbstractVector)
    jpm = jump(fm)
    haskey(jpm, _UPPER_BOUND_CON_KEY) && delete!(jpm, _UPPER_BOUND_CON_KEY)
    v = get_jpvars(jpm)
    jpm[_UPPER_BOUND_CON_KEY] = @JuMP.constraint(jpm, 
        v .<= ub, 
        base_name = string(_UPPER_BOUND_CON_KEY)
    )
    return fm
end
get_upper_bound_cons(fm::FluxOpModel) = jump(fm, _UPPER_BOUND_CON_KEY)

