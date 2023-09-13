# TODO: evaluate using JuMP.shadow_price
# Rigth now the dual_proce we have is between variables, no the objective function

## ------------------------------------------------------------------
## ------------------------------------------------------------------
function _lb_safe_setter!(opm, v0i::Integer, l)
    u = ub(opm, v0i)
    u < l && error("u < l detected")
    lb!(opm, v0i, l)
    return nothing
end

function _ub_safe_setter!(opm, v0i::Integer, u)
    l = lb(opm, v0i)
    u < l && error("u < l detected")
    ub!(opm, v0i, u)
    return nothing
end

# ------------------------------------------------------------------
# Compute df/d_bound_v0 where f is the current opm obj function.
# 'interval' set the test points for computing the price
function bound_dual_prices(opm::OpModel, v0_id, test_points, bound_id; 
        delta_mat = nothing, 
        obj_delta_vec = nothing,
        optimize_fun! = optimize!, 
        dovars = true
    )
    
    v0i = colindex(opm, v0_id)
    v0lb_bk, v0ub_bk = bounds(opm, v0i)

    # select setter
    if bound_id == :lb; setter! = _lb_safe_setter!
        elseif bound_id == :ub; setter! = _ub_safe_setter!
        else; error("'bound_id' must be either :lb or :ub, found $(bound_id)")
    end
    
    P = length(test_points)
    N = length(colids(opm))
    if dovars && isnothing(delta_mat)
        delta_mat = zeros(P, N) # delta_mat[test_point, flux] 
    end
    if isnothing(obj_delta_vec)
        obj_delta_vec = zeros(P)
    end
    for (i, b) in enumerate(test_points)
        setter!(opm, v0i, b)
        optimize_fun!(opm)
        if dovars
            delta_mat[i, :] .= solution(opm)
        end
        obj_delta_vec[i] = objective_value(opm)

    end
    bounds!(opm, v0i, v0lb_bk, v0ub_bk)

    # compute line
    # objective
    _, obj_m, obj_err = _linear_fit(test_points, obj_delta_vec)
    # @info "bound_dual_prices"
    # @show v0_id
    # @show test_points
    # @show obj_delta_vec

    # variables
    if dovars
        vars_ms, vars_errs = zeros(N), zeros(N)
        for (i, rxn_vals) in enumerate(eachcol(delta_mat))
            _, vars_ms[i], vars_errs[i] = _linear_fit(test_points, rxn_vals)
        end
    else
        vars_ms, vars_errs =  Float64[], Float64[]
    end
    return obj_m, obj_err, vars_ms, vars_errs
end

lb_dual_prices(opm::OpModel, v0_id, test_points; kwargs...) = 
    bound_dual_prices(opm, v0_id, test_points, :lb; kwargs...)
ub_dual_prices(opm::OpModel, v0_id, test_points; kwargs...) = 
    bound_dual_prices(opm, v0_id, test_points, :ub; kwargs...)

# 'v_params' must be a vector of (id, test_points, bound_id) tuples/vectors
function bound_dual_prices(opm::OpModel, v_params::Vector;
        kwargs...
    )
    obj_ms, obj_errs = [], []
    vars_mss, vars_errss = [], []
    for (id, test_points, bound_id) in v_params
        obj_m, obj_err, vars_ms, vars_errs = bound_dual_prices(opm, id, test_points, bound_id; kwargs...)
        push!(obj_ms, obj_m); push!(obj_errs, obj_err)
        push!(vars_mss, vars_ms); push!(vars_errss, vars_errs)
    end
    return obj_m, obj_err, vars_ms, vars_errs
end

# ------------------------------------------------------------------
# Compute df/d_v0 where f is the current opm obj function.
# 'interval' set the test points for computing the price
function flux_dual_prices(opm::OpModel, v0_id, test_points;
        dx = 0.0, 
        delta_mat = nothing, 
        obj_delta_vec = nothing,
        optimize_fun! = optimize!, 
        dovars = triue
    )

    v0i = colindex(opm, v0_id)
    v0lb_bk, v0ub_bk = bounds(opm, v0i)

    P = length(test_points)
    N = length(colids(opm))
    if dovars && isnothing(delta_mat)
        delta_mat = zeros(P, N) # delta_mat[test_point, flux] 
    end
    if isnothing(obj_delta_vec)
        obj_delta_vec = zeros(P)
    end
    for (i, b) in enumerate(test_points)
        
        bounds!(opm, v0i, b - dx, b + dx)
        optimize_fun!(opm)
        if dovars
            delta_mat[i, :] = solution(opm)
        end
        obj_delta_vec[i] = objective_value(opm)
    end
    bounds!(opm, v0i, v0lb_bk, v0ub_bk)

    # compute line
    # objective
    obj_delta_vec
    _, obj_m, obj_err = _linear_fit(test_points, obj_delta_vec)

    # variables
    if dovars
        vars_ms, vars_errs = zeros(N), zeros(N)
        for (i, rxn_vals) in enumerate(eachcol(delta_mat))
            _, vars_ms[i], vars_errs[i] = _linear_fit(test_points, rxn_vals)
        end
    else
        vars_ms, vars_errs = Float64[], Float64[]
    end
    
    return obj_m, obj_err, vars_ms, vars_errs
end

# 'v_params' must be a vector of (id, test_points) tuples/vectors
function flux_dual_prices(opm::OpModel, v_params::Vector; kwargs...)
    obj_ms, obj_errs = [], []
    vars_mss, vars_errss = [], []
    for (id, test_points) in v_params
        obj_m, obj_err, vars_ms, vars_errs = flux_dual_prices(opm, id, test_points; kwargs...)
        push!(obj_ms, obj_m); push!(obj_errs, obj_err)
        push!(vars_mss, vars_ms); push!(vars_errss, vars_errs)
    end
    return obj_m, obj_err, vars_ms, vars_errs
end

## ------------------------------------------------------------------
# TODO: update this
# Maybe is too specific, use a oniter function
# ## ------------------------------------------------------------------
# # v0_id, test_points, bound_id
# function bound_dual_prices_ratio_mat(opm::OpModel, 
#         v0_id, v0_test_points, v0_bound_id, 
#         v1_id, v1_test_points, v1_bound_id, 
#         obj_id; 
#         delta_mat = nothing, 
#         ratio_mat = nothing, 
#         optimize_fun! = optimize!, 
#         verbose = false,
#         npoints = 5,
#         v0_ϵ = 5e-2, 
#         v1_ϵ = 5e-2, 
#         atol = 1e-5 # tol for ms
#     )

#     v0_idx = colindex(opm, v0_id)
#     v1_idx = colindex(opm, v1_id)
#     obj_idx = colindex(opm, obj_id)

#     if isnothing(ratio_mat)
#         ratio_mat = zeros(length(v0_test_points), length(v1_test_points))
#     end

#     iter = enumerate(Iterators.product(v1_test_points, v0_test_points))

#     # select setter
#     if v0_bound_id == :lb; v0_setter! = _lb_safe_setter!
#         elseif v0_bound_id == :ub; v0_setter! = _ub_safe_setter!
#         else; error("'v0_bound_id' must be either :lb or :ub, found $(v0_bound_id)")
#     end

#     # select setter
#     if v1_bound_id == :lb; v1_setter! = _lb_safe_setter!
#         elseif v1_bound_id == :ub; v1_setter! = _ub_safe_setter!
#         else; error("'v1_bound_id' must be either :lb or :ub, found $(v1_bound_id)")
#     end

#     # epsilon
#     v0_ϵ = v0_ϵ * sum(abs, diff(v0_test_points)) / (length(v0_test_points) - 1)
#     v1_ϵ = v1_ϵ * sum(abs, diff(v1_test_points)) / (length(v1_test_points) - 1)
#     # @show v0_ϵ, v1_ϵ

#     @time for (i, (v1_b, v0_b)) in iter
        
#         # Info
#         verbose && iszero(rem(i, 10)) && print("Doing: ", i, "/", length(iter), "\r")

#         # contextualize
#         v0_setter!(opm, v0_idx, v0_b)
#         v1_setter!(opm, v1_idx, v1_b)

#         # v0 double price
#         x0 = v0_b
#         x1 = x0 + v0_ϵ
#         # @assert x0 < 0 && x1 < 0
#         # @show x0, x1
#         test_points = range(x0, x1; length = npoints)
#         ms, errs = bound_dual_prices(opm, v0_idx, test_points, v0_bound_id; optimize_fun!, delta_mat)
#         v0_obj_m, v0_obj_err = ms[obj_idx], errs[obj_idx]
#         # @show v0_obj_err

#         # v1 double price
#         x0 = v1_b
#         x1 = x0 + v1_ϵ
#         # @assert x0 < 0 && x1 < 0
#         # @show x0, x1
#         test_points = range(x0, x1; length = npoints)
#         ms, errs = bound_dual_prices(opm, v1_idx, test_points, v1_bound_id; optimize_fun!, delta_mat)
#         v1_obj_m, v1_obj_err = ms[obj_idx], errs[obj_idx]
#         # @show v1_obj_err

#         ratio_mat[i] = abs(v0_obj_m) < atol && abs(v1_obj_m) < atol ? 
#             -1.0 : abs(v0_obj_m) / (abs(v0_obj_m) + abs(v1_obj_m))

#     end

#     return ratio_mat
# end

# ## ------------------------------------------------------------------
# lb_dual_prices_ratio_mat(opm::OpModel, v0_id, v0_test_points, v1_id, v1_test_points, obj_id; kwargs...) = 
#     bound_dual_prices_ratio_mat(opm, v0_id, v0_test_points, :lb, v1_id, v1_test_points, :lb, obj_id; kwargs...)
# ub_dual_prices_ratio_mat(opm::OpModel, v0_id, v0_test_points, v1_id, v1_test_points, obj_id; kwargs...) = 
#     bound_dual_prices_ratio_mat(opm, v0_id, v0_test_points, :ub, v1_id, v1_test_points, :ub, obj_id; kwargs...)
