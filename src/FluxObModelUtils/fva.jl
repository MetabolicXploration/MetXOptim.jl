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
    for (bi, ri) in enumerate(ridxs)
        fvalb[bi], fvaub[bi] = fva!(opm, ri; T)
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
        bash_len = 20,
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
    fvalb = lb(net, ridxs) |> copy
    fvaub = ub(net, ridxs) |> copy

    # Iterate
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t$nths)  "))
    
    nths = nthreads()
    ch = MetXBase.chunkedChannel(ridxs; 
        # nchnks = 2*nths
        chnklen = bash_len
    )
    # c = [0 for _ in 1:nths] # Test

    @threads for _ in 1:2*nths
        th = threadid()
        for chk in ch
            # c[th] += 1
            opm = opm_pool[th]
            _ridxs, _lbs, _ubs = fva!(opm; 
                ridxs = collect(chk),
                verbose = false
            )
            MetXBase._setindex!(fvalb, _ridxs, _lbs)
            MetXBase._setindex!(fvaub, _ridxs, _ubs)
            verbose && next!(prog; step = length(_ridxs))
        end
    end
    verbose && finish!(prog)
    # @show c

    return ridxs, fvalb, fvaub
end 

# ------------------------------------------------------------------
export fva
function fva(net::MetNet, jump_args...;
        th = false,
        bash_len = 20,
        ridxs = eachindex(reactions(net)), 
        verbose = false,
        opmodel_kwargs...
    )
    if th
        return fva_th(net, jump_args...; ridxs, verbose, bash_len, opmodel_kwargs...)
    else
        opm = FBAFluxOpModel(net, jump_args...; opmodel_kwargs...)
        return fva!(opm; ridxs, verbose)
    end
end