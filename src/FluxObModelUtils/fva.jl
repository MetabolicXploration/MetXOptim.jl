# TODO: create a size(opm::FluxOpModel)
export fva!
function fva!(opm::FluxOpModel, ridx::Int; T = Float64)
    
    ri = rxnindex(opm, ridx)

    c1 = one(T)
    
    # max
    set_linear_obj!(opm, ri, c1)
    sol = fba!(opm)
    ub = solution(sol, ri)
    
    # max
    set_linear_obj!(opm, ri, -c1)
    sol = fba!(opm)
    lb = solution(sol, ri)

    return lb, ub
end

function fva!(opm::FluxOpModel; 
        ridxs = eachindex(reactions(opm)), 
        verbose = false
    )

    # TODO: make FVA only over the independent fluxes (FullRankNet)

    ridxs = rxnindex(opm, ridxs)

    # bounds
    fvalb = lb(opm, ridxs)
    fvaub = ub(opm, ridxs)

    T = eltype(fvalb)

    # iterate
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t1)"))
    for ri in ridxs
        fvalb[ri], fvaub[ri] = fva!(opm, ri; T)
        verbose && next!(prog)
    end
    verbose && finish!(prog)

    # box
    return ridxs, fvalb, fvaub
end

# ------------------------------------------------------------------
export fva_th
function fva_th(net::MetNet, jump_args...;
        ridxs = eachindex(reactions(net)),
        verbose = false,
        opmodel_kwargs...
    )

    nths = nthreads()
    
    # models pool
    opm_pool = [ 
        FBAFluxOpModel(net, jump_args...; opmodel_kwargs...)
        for _ in 1:nths
    ]
    
    ridxs = rxnindex(net, ridxs)

    # bounds
    fvalb = lb(net, ridxs)
    fvaub = ub(net, ridxs)

    T = eltype(fvalb)

    # Iterate
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t$nths)  "))
    @threads for ri in ridxs
        th = threadid()
        opm = opm_pool[th]
        fvalb[ri], fvaub[ri] = fva!(opm, ri; T)
        verbose && next!(prog)
    end
    verbose && finish!(prog)

    return ridxs, fvalb, fvaub
end 

# ------------------------------------------------------------------
export fva
function fva(net::MetNet, jump_args...;
        th = false,
        ridxs = eachindex(reactions(net)), 
        verbose = false,
        opmodel_kwargs...
    )
    if th
        return fva_th(net, jump_args...; ridxs, verbose, opmodel_kwargs...)
    else
        opm = FBAFluxOpModel(net, jump_args...; opmodel_kwargs...)
        return fva!(opm; ridxs, verbose)
    end
end