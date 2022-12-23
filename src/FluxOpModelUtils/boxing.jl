# # TODO: add flag for reducing or not (in addition of specific fluxes protection)
# export boxxing
# function boxxing(net::MetNet; 
#         protect = []
#     )
# end

## ------------------------------------------------------------------
function _fit_dim_gd!(
        opm::FluxOpModel;
        target_flx::Int,
        target_upfun!::Function,
        objfun!::Function, 
        objfun_target::Real,
        prog_init::Int,   # iter to start measuring progress
        prog_th::Real = 1e-3,   # minimum progress
        max_box,
        
        # gd params
        verbose = true,
        x0, x1, maxΔx,
        minΔx = 1e-3,
        err_th = 1e-3,
        maxiter = 500,
    )

    # state globals
    safe_sol = x0
    obj_val0 = objfun!(opm)
    obj_val = obj_val0
    prog = nothing


    up_fun = (gdmodel) -> begin
        b = MetXBase.gd_value(gdmodel)
        target_upfun!(opm, b)
        obj_val = objfun!(opm)
        return obj_val
    end

    oniter! = (gdmodel) -> begin

        iter = gdmodel.iter
        # verbose && @info("Here iter: $(gdmodel.iter)")
        
        # check inbox
        lb, ub = bounds(opm, target_flx)
        lb0, ub0 = max_box
        inbound = lb >= lb0 && ub <= ub0
        
        # prog
        prog = gdmodel.ϵii / gdmodel.ϵi
        
        # verbose && @info("Checks", (obj_val, obj_val0), (lb, lb0), (ub, ub0), prog)
        
        # check expanding
        if iter >= prog_init
            if isnan(prog) || abs(1.0 - prog) < prog_th # stop if no progress
                (iter == prog_init) && (safe_sol = x0) # reject work
                return true
            end
        end
        inbound || return true

        # save if all checks passed
        safe_sol = MetXBase.gd_value(gdmodel)

        return false
    end

    gdmodel = MetXBase.grad_desc(up_fun; 
        target = objfun_target, 
        oniter!,
        gdth = err_th,
        x0, x1, minΔx, maxΔx, 
        verbose,
        maxiter, 
        # toshow = [(:prog, prog)]
    )

    # up to safe or reverse
    target_upfun!(opm, safe_sol)

    return nothing
end

## ------------------------------------------------------------------
_fit_dim_gd_objfun!(opm) = (optimize!(opm); objective_value(opm))
_fit_lb_target_upfun!(target_flx) = (opm, b) -> lb!(opm, target_flx, b)
_fit_ub_target_upfun!(target_flx) = (opm, b) -> ub!(opm, target_flx, b)

export fit_lb!
function fit_lb!(
        opm::FluxOpModel, ider, obj_target;
        x0 = lb(opm, ider),                     # The initial point
        x1 = lb(opm, ider) - 1e-3,              # The next initial point
        prog_init = 3,
        prog_th::Real = 1e-3,                   
        verbose = false,
        max_box = (-Inf, Inf),
        maxΔx = 1.0,
        kwargs...
    )

    target_flx = rxnindex(opm, ider)

    _fit_dim_gd!(
        opm; 
        target_flx, 
        objfun_target = obj_target, 
        objfun! = _fit_dim_gd_objfun!,
        target_upfun! = _fit_lb_target_upfun!(target_flx),
        prog_init, prog_th,
        verbose,
        max_box, 
        x0, x1, maxΔx,
        kwargs...
    )
    return opm
end

export fit_ub!
function fit_ub!(
        opm::FluxOpModel, ider, obj_target;
        x0 = ub(opm, ider),                     # The initial point
        x1 = ub(opm, ider) + 1e-3,              # The next initial point
        prog_init = 3,
        prog_th::Real = 1e-3,                   
        verbose = false,
        max_box = (-Inf, Inf),
        maxΔx = 1.0, 
        kwargs...
    )

    target_flx = rxnindex(opm, ider)

    _fit_dim_gd!(
        opm; 
        target_flx, 
        objfun_target = obj_target, 
        objfun! = _fit_dim_gd_objfun!,
        target_upfun! = _fit_ub_target_upfun!(target_flx),
        prog_init, prog_th,
        verbose,
        max_box, 
        x0, x1, maxΔx,
        kwargs...
    )
    return opm
end

## ------------------------------------------------------------------
# add box bounds but checking an objective (the current at opm) is protected
function _safe_box!(opm::FluxOpModel, ridxs, box_lb, box_ub; 
        batch_len = min(length(opm), 10),
        verbose = true,
        obj_prot_tol = 1e-3,
    )

    # objval0
    optimize!(opm)
    objval0 = objective_value(opm)

    # copy
    lb0, ub0 = bounds(opm)
    
    rbatchs = MetXBase.chunks(ridxs; chnklen = batch_len)
    verbose && (prog = ProgressUnknown(; desc = "Fixing objective"))
    
    depv = linobj_dependence(opm)
    for rbatch in rbatchs
        rbatch = collect(rbatch)

        # box!
        bounds!(opm, rbatch; lb = box_lb[rbatch], ub = box_ub[rbatch])
        
        # check
        try; optimize!(opm)
            objval1 = objective_value(opm)
        catch
            objval1 = NaN
        end

        if isnan(objval1)

            # restore
            bounds!(opm, rbatch; lb = lb0[rbatch], ub = ub0[rbatch])
            
            for rxi in rbatch

                verbose && next!(prog; 
                    showvalues = [
                        (:rxn, reactions(opm, rxi)),
                        (:objval0, objval0),
                        (:objval1, objval1),
                        (:orig, (lb0[rxi], ub0[rxi])),
                        (:box, (box_lb[rxi], box_ub[rxi])),
                    ]
                )
                
                # box! rxi
                bounds!(opm, rxi; lb = box_lb[rxi], ub = box_ub[rxi])
                
                # check nan
                try; optimize!(opm)
                    objval1 = objective_value(opm)
                catch
                    objval1 = NaN
                end

                # unbox! if failed
                isnan(objval1) && bounds!(opm, rxi; lb = lb0[rxi], ub = ub0[rxi])
            end

        end

        # grad desc
        optimize!(opm)
        objval1 = objective_value(opm)
        if !isapprox(objval0, objval1; rtol = obj_prot_tol) 

            for (rxi, dep) in zip(rbatch, depv[rbatch])
        
                verbose && next!(prog; 
                    showvalues = [
                        (:rxn, reactions(opm, rxi)),
                        (:objval0, objval0),
                        (:objval1, objval1),
                        (:orig, (lb0[rxi], ub0[rxi])),
                        (:box, (box_lb[rxi], box_ub[rxi])),
                    ]
                )
                
                (dep == 0) && continue
                
                fitfun! = dep == 1 ? fit_ub! : fit_lb!
                fitfun!(opm, rxi, objval0; 
                    verbose = false, max_box = (lb0[rxi], ub0[rxi])
                )
                
                optimize!(opm)
                objval1 = objective_value(opm)
                
                isapprox(objval0, objval1; rtol = obj_prot_tol) && break
            end
            
        end # check objval0 ~ objval1

        verbose && next!(prog; 
            showvalues = [
                (:rxn, reactions(opm, first(rbatch))),
                (:objval0, objval0),
                (:objval1, objval1)
            ]
        )

    end # for rbatch in rbatchs
    verbose && (finish!(prog); flush(stdout); flush(stderr))
    
    return opm
    
end

export box, box!
function box!(opm::FluxOpModel,
        ridxs = eachindex(reactions(opm));
        verbose = false,
        protect_obj = false,
        obj_prot_tol = 1e-3,
        round_digs = 8,
        batch_len = min(length(opm), 10),
    )

    # objval0
    if protect_obj
        obj0 = objective_function(opm)
    end

    # fva
    ridxs = rxnindex(opm, ridxs)
    lb1, ub1 = fva!(opm, ridxs; verbose)
    lb1 .= round.(lb1; digits = round_digs)
    ub1 .= round.(ub1; digits = round_digs)

    # objval1
    if protect_obj
        set_objective_function(opm, obj0)
        _safe_box!(opm, ridxs, lb1, ub1; 
            batch_len, verbose, obj_prot_tol
        )
    else
        bounds!(opm, ridxs; lb = lb1, ub = ub1)
    end

    return opm

end

function box!(net::MetNet, solver; kwargs...) 

    opm = FBAFluxOpModel(net, solver)
    opm = box!(opm; kwargs...)

    lb!(net, lb(opm))
    ub!(net, ub(opm))
    return net
end

# TODO: new name sug: inscribe!
function box(net::MetNet, solver; 
        reduce = true,
        eps = 0.0, protect = [],
        box_kwargs...
    ) 

    if reduce # empty_fixxed! touch S and b
        net = deepcopy(net)
    else
        net = MetNet(net; 
            lb = copy(lb(net)),
            ub = copy(ub(net)),
        )
    end
    
    box!(net, solver; box_kwargs...) 
    
    
    if reduce
        empty_fixxed!(net; eps, protect)
        net = emptyless_model(net)
    end

    return net
end