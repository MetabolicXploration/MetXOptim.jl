## ------------------------------------------------------------------
## ------------------------------------------------------------------
function _lb_safe_setter!(opm, v0i::Int, l)
    u = ub(opm, v0i)
    u < l && error("u < l detected")
    lb!(opm, v0i, l)
    return nothing
end

function _ub_safe_setter!(opm, v0i::Int, u)
    l = lb(opm, v0i)
    u < l && error("u < l detected")
    ub!(opm, v0i, u)
    return nothing
end

# ------------------------------------------------------------------
# Compute df/d_bound_v0 where f is the current opm obj function.
# 'interval' set the test points for computing the price
export bound_dual_prices
function bound_dual_prices(opm::FluxOpModel, v0id, test_points, bound_id; 
        delta_mat = nothing, 
        optimize_fun! = optimize!
    )
    
    v0i = rxnindex(opm, v0id)
    v0lb_bk, v0ub_bk = bounds(opm, v0i)

    # select setter
    if bound_id == :lb
        setter! = _lb_safe_setter!
    elseif bound_id == :ub
        setter! = _ub_safe_setter!
    else
        error("'bound_id' must be either :lb or :ub, found $(bound_id)")
    end
    
    P = length(test_points)
    N = length(reactions(opm))
    if isnothing(delta_mat)
        delta_mat = zeros(P, N) # delta_mat[test_point, flux] 
    end
    for (i, b) in enumerate(test_points)
        
        setter!(opm, v0i, b)
        optimize_fun!(opm)
        delta_mat[i, :] = solution(opm)

    end
    bounds!(opm, v0i, v0lb_bk, v0ub_bk)

    ms, errs = zeros(N), zeros(N)
    for (i, rxn_vals) in enumerate(eachcol(delta_mat))
        _, ms[i], errs[i] = MetXBase._linear_fit(test_points, rxn_vals)
    end
    return ms, errs
end

lb_dual_prices(opm::FluxOpModel, v0id, test_points) = 
    bound_dual_prices(opm, v0id, test_points, :lb)
ub_dual_prices(opm::FluxOpModel, v0id, test_points) = 
    bound_dual_prices(opm, v0id, test_points, :ub)

# ------------------------------------------------------------------
# Compute df/d_v0 where f is the current opm obj function.
# 'interval' set the test points for computing the price
export flux_dual_prices
function flux_dual_prices(opm::FluxOpModel, v0id, test_points;
        dx = 0.0, 
        delta_mat = nothing, 
        optimize_fun! = optimize!
    )

    v0i = rxnindex(opm, v0id)
    v0lb_bk, v0ub_bk = bounds(opm, v0i)

    P = length(test_points)
    N = length(reactions(opm))
    if isnothing(delta_mat)
        delta_mat = zeros(P, N) # delta_mat[test_point, flux] 
    end
    for (i, b) in enumerate(test_points)
        
        bounds!(opm, v0i, b - dx, b + dx)
        optimize_fun!(opm)
        delta_mat[i, :] = solution(opm)

    end
    bounds!(opm, v0i, v0lb_bk, v0ub_bk)

    ms, errs = zeros(N), zeros(N)
    for (i, rxn_vals) in enumerate(eachcol(delta_mat))
        _, ms[i], errs[i] = MetXBase._linear_fit(test_points, rxn_vals)
    end
    return ms, errs
end