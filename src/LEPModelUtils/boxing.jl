## ---------------------------------------------
function _just_box!(lep::LEPModel, solver; 
        colidxs = eachindex(colids(lep)),
        nths = 1,
        verbose = false, 
        round_digs = 8
    )

    # fva bounds
    colidxs = colindex(lep, colidxs)
    lb1, ub1 = fva(lep, solver, colidxs; nths,  verbose)
    lb1 .= round.(lb1; digits = round_digs)
    ub1 .= round.(ub1; digits = round_digs)

    # Update bounds
    lb!(lep, lb1)
    ub!(lep, ub1)

    return lep

end

## ---------------------------------------------
function _reduce_and_box(lep::LEPModel, solver; 
        # fva
        colidxs = eachindex(colids(lep)),
        nths = 1,
        verbose = false, 
        round_digs = 8,

        # reduce
        eps = 0.0, 
        protect = []
    )

    # TODO: here Im making two copies of the model
    # The problem is that empty_fixxed! write S

    # copy
    lep = deepcopy(lep)
    
    # box!
    _just_box!(lep, solver; colidxs, nths, verbose, round_digs)
    
    # reduce
    empty_fixxed!(lep; eps, protect)
    lep = emptyless_model(lep)

    return lep
end

## ---------------------------------------------
# interface

function box(lep::LEPModel, solver; 
        # fva
        colidxs = eachindex(colids(lep)),
        nths = 1,
        verbose = false, 
        round_digs = 8,

        # reduce
        reduce = true,
        eps = 0.0, 
        protect = []
    )

    if reduce
        lep = _reduce_and_box(lep, solver; colidxs, nths, verbose, round_digs, eps, protect)
    else
        # copy
        lep = LEPModel(lep; 
            lb = copy(lb(lep)),
            ub = copy(ub(lep)),
        )
        _just_box!(lep, solver; colidxs, nths, verbose, round_digs)
    end
    
    return lep
end

# lep interface
box(model, args...; kwargs...) = box(lepmodel(model), args...; kwargs...)

## ---------------------------------------------
## ---------------------------------------------
## ---------------------------------------------
## ---------------------------------------------
# DEPRECATED

# function box!(lep::LEPModel, solver; kwargs...) 

#     opm = FBAOpModel(lep, solver)
#     opm = box!(opm; kwargs...)

#     lb!(lep, lb(opm))
#     ub!(lep, ub(opm))
#     return lep
# end

# # TODO: new name sug: inscribe!, fullrank_box
# function box(lep::LEPModel, solver; 
#         reduce = true,
#         eps = 0.0, protect = [],
#         box_kwargs...
#     ) 

#     if reduce # empty_fixxed! touch S and b
#         lep = deepcopy(lep)
#     else
#         lep = LEPModel(lep; 
#             lb = copy(lb(lep)),
#             ub = copy(ub(lep)),
#         )
#     end
    
#     box!(lep, solver; box_kwargs...)
    
#     if reduce
#         empty_fixxed!(lep; eps, protect)
#         lep = emptyless_model(lep)
#     end

#     return lep
# end

# # lep interface
# box(model, args...; kwargs...) = box(lepmodel(model), args...; kwargs...)


# TODO: Add all functionalities to box(lep::LEPModel...)
# ## ------------------------------------------------------------------
# function box!(opm::OpModel,
#         colidxs = eachindex(colids(opm));
#         verbose = false,
#         protect_obj = false,
#         obj_prot_tol = 1e-3,
#         round_digs = 8,
#         batch_len = min(length(opm), 10),
#     )

#     # objval0
#     if protect_obj
#         obj0 = objective_function(opm)
#     end

#     # fva
#     colidxs = colindex(opm, colidxs)
#     lb1, ub1 = fva!(opm, colidxs; verbose)
#     lb1 .= round.(lb1; digits = round_digs)
#     ub1 .= round.(ub1; digits = round_digs)

#     # objval1
#     if protect_obj
#         set_objective_function!(opm, obj0)
#         _safe_box!(opm, colidxs, lb1, ub1; 
#             batch_len, verbose, obj_prot_tol
#         )
#     else
#         bounds!(opm, colidxs; lb = lb1, ub = ub1)
#     end

#     return opm

# end

# # # TODO: add flag for reducing or not (in addition of specific fluxes protection)
# # function boxxing(lep::LEPModel; 
# #         protect = []
# #     )
# # end

# # TODO: add lep interface
# # TODO: del _bound_grad or improve it

# ## ------------------------------------------------------------------
# # add box bounds but checking an objective (the current at opm) is protected
# function _safe_box!(opm::OpModel, colidxs, box_lb, box_ub; 
#         batch_len = min(length(opm), 10),
#         verbose = true,
#         obj_prot_tol = 1e-3,
#     )

#     # objval0
#     optimize!(opm)
#     objval0 = objective_value(opm)

#     # copy
#     lb0, ub0 = bounds(opm)
    
#     rbatchs = MetXBase.chunks(colidxs; chnklen = batch_len)
#     verbose && (prog = ProgressUnknown(; desc = "Fixing objective"))
    
#     depv = objective_dependence(opm)
#     objval1 = NaN

#     for rbatch in rbatchs
#         rbatch = collect(rbatch)

#         # box!
#         bounds!(opm, rbatch; lb = box_lb[rbatch], ub = box_ub[rbatch])
        
#         # check
#         objval1 = _try_opt_objective!(opm)
#         if isnan(objval1)

#             # TODO: make this work but robust 
#             error("Objective value not recoverable, boxxing failed")

#             # restore
#             bounds!(opm, rbatch; lb = lb0[rbatch], ub = ub0[rbatch])
            
#             for rxi in rbatch

#                 verbose && next!(prog; 
#                     showvalues = [
#                         (:rxn, colids(opm, rxi)),
#                         (:objval0, objval0),
#                         (:objval1, objval1),
#                         (:orig, (lb0[rxi], ub0[rxi])),
#                         (:box, (box_lb[rxi], box_ub[rxi])),
#                     ]
#                 )
                
#                 # box! rxi
#                 bounds!(opm, rxi; lb = box_lb[rxi], ub = box_ub[rxi])
                
#                 # check nan
#                 objval1 = _try_opt_objective!(opm)

#                 # unbox! if failed
#                 isnan(objval1) && bounds!(opm, rxi; lb = lb0[rxi], ub = ub0[rxi])
#             end

#         end

#         # grad desc
#         objval1 = _try_opt_objective!(opm)

#         if !isapprox(objval0, objval1; rtol = obj_prot_tol) 

#             # TODO: make this work but robust 
#             error("Objective value not recoverable, boxxing failed")

#             for (rxi, dep) in zip(rbatch, depv[rbatch])
        
#                 verbose && next!(prog; 
#                     showvalues = [
#                         (:rxn, colids(opm, rxi)),
#                         (:objval0, objval0),
#                         (:objval1, objval1),
#                         (:orig, (lb0[rxi], ub0[rxi])),
#                         (:box, (box_lb[rxi], box_ub[rxi])),
#                     ]
#                 )
                
#                 (dep == 0) && continue
                
#                 fitfun! = dep == 1 ? ub_grad_desc! : lb_grad_desc!
#                 fitfun!(opm, rxi, objval0; 
#                     verbose = false, max_box = (lb0[rxi], ub0[rxi])
#                 )
                
#                 objval1 = _try_opt_objective!(opm)
                
#                 isapprox(objval0, objval1; rtol = obj_prot_tol) && break
#             end
            
#         end # check objval0 ~ objval1

#         verbose && next!(prog; 
#             showvalues = [
#                 (:rxn, colids(opm, first(rbatch))),
#                 (:objval0, objval0),
#                 (:objval1, objval1)
#             ]
#         )

#     end # for rbatch in rbatchs
#     verbose && (finish!(prog); flush(stdout); flush(stderr))
    
#     return opm
    
# end

# ## ------------------------------------------------------------------
# # Make a gradient descent moving a bound till an objective is match
# function _bound_grad_desc!(
#         opm::OpModel;
#         target_flx::Int,
#         target_upfun!::Function,
#         objfun!::Function, 
#         objfun_target::Real,
#         prog_init::Int,   # iter to start measuring progress
#         prog_th::Real = 1e-3,   # minimum progress
#         max_box,
        
#         # gd params
#         verbose = true,
#         x0, x1, maxΔx,
#         minΔx = 1e-3,
#         err_th = 1e-3,
#         maxiter = 500,
#     )

#     # state globals
#     safe_sol = x0
#     obj_val0 = objfun!(opm)
#     obj_val = obj_val0
#     prog = nothing


#     up_fun = (gdmodel) -> begin
#         b = MetXBase.gd_value(gdmodel)
#         target_upfun!(opm, b)
#         obj_val = objfun!(opm)
#         return obj_val
#     end

#     oniter! = (gdmodel) -> begin

#         iter = gdmodel.iter
#         # verbose && @info("Here iter: $(gdmodel.iter)")
        
#         # check inbox
#         lb, ub = bounds(opm, target_flx)
#         lb0, ub0 = max_box
#         inbound = lb >= lb0 && ub <= ub0
        
#         # prog
#         prog = gdmodel.ϵii / gdmodel.ϵi
        
#         # verbose && @info("Checks", (obj_val, obj_val0), (lb, lb0), (ub, ub0), prog)
        
#         # check expanding
#         if iter >= prog_init
#             if isnan(prog) || abs(1.0 - prog) < prog_th # stop if no progress
#                 (iter == prog_init) && (safe_sol = x0) # reject work
#                 return true
#             end
#         end
#         inbound || return true

#         # save if all checks passed
#         safe_sol = MetXBase.gd_value(gdmodel)

#         return false
#     end

#     gdmodel = MetXBase.grad_desc(up_fun; 
#         target = objfun_target, 
#         oniter!,
#         gdth = err_th,
#         x0, x1, minΔx, maxΔx, 
#         verbose,
#         maxiter, 
#         # toshow = [(:prog, prog)]
#     )

#     # up to safe or reverse
#     target_upfun!(opm, safe_sol)

#     return nothing
# end

# ## ------------------------------------------------------------------
# _fit_dim_gd_objfun!(opm) = (optimize!(opm); objective_value(opm))
# _fit_lb_target_upfun!(target_flx) = (opm, b) -> lb!(opm, target_flx, b)
# _fit_ub_target_upfun!(target_flx) = (opm, b) -> ub!(opm, target_flx, b)

# function lb_grad_desc!(
#         opm::OpModel, ider, obj_target;
#         x0 = lb(opm, ider),                     # The initial point
#         x1 = lb(opm, ider) - 1e-3,              # The next initial point
#         prog_init = 3,
#         prog_th::Real = 1e-3,
#         verbose = false,
#         max_box = (-Inf, Inf),
#         maxΔx = 1.0,
#         kwargs...
#     )

#     target_flx = colindex(opm, ider)

#     _bound_grad_desc!(
#         opm; 
#         target_flx, 
#         objfun_target = obj_target, 
#         objfun! = _fit_dim_gd_objfun!,
#         target_upfun! = _fit_lb_target_upfun!(target_flx),
#         prog_init, prog_th,
#         verbose,
#         max_box, 
#         x0, x1, maxΔx,
#         kwargs...
#     )
#     return opm
# end

# function ub_grad_desc!(
#         opm::OpModel, ider, obj_target;
#         x0 = ub(opm, ider),                     # The initial point
#         x1 = ub(opm, ider) + 1e-3,              # The next initial point
#         prog_init = 3,
#         prog_th::Real = 1e-3,                   
#         verbose = false,
#         max_box = (-Inf, Inf),
#         maxΔx = 1.0, 
#         kwargs...
#     )

#     target_flx = colindex(opm, ider)

#     _bound_grad_desc!(
#         opm; 
#         target_flx, 
#         objfun_target = obj_target, 
#         objfun! = _fit_dim_gd_objfun!,
#         target_upfun! = _fit_ub_target_upfun!(target_flx),
#         prog_init, prog_th,
#         verbose,
#         max_box, 
#         x0, x1, maxΔx,
#         kwargs...
#     )
#     return opm
# end

# ## ------------------------------------------------------------------
# function _try_opt_objective!(opm)
#     try; optimize!(opm)
#         return objective_value(opm)
#         catch; return NaN
#     end
# end
