# TODO: create a size(opm::FluxOpModel)
function _fva!(opm::FluxOpModel, ridx::Int; T = Float64)
    
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

export fva!
fva!(opm::FluxOpModel, ridx::Int; T = Float64) = keepobj!(() -> _fva!(opm, ridx; T), opm)

function _fva!(opm::FluxOpModel; 
        ridxs = eachindex(reactions(opm)), 
        oniter = nothing,
    )
    # TODO: make FVA only over the independent fluxes (FullRankNet)
    
    # ridxs
    ridxs = rxnindex(opm, ridxs)

    # bounds
    fvalb = lb(opm, ridxs)
    fvaub = ub(opm, ridxs)

    T = eltype(fvalb)

    # iterate
    keepobj!(opm) do
        for (bi, ri) in enumerate(ridxs)
            fvalb[bi], fvaub[bi] = _fva!(opm, ri; T)
            run_callbacks(oniter, opm)
        end
    end

    # box
    return fvalb, fvaub
end

function fva!(opm::FluxOpModel; 
        ridxs = eachindex(reactions(opm)), 
        oniter = nothing,
        verbose = true
    )   

    # config
    verbose = config(opm, :verbose, verbose)
    
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t1)  "))
    _upprog = (opm) -> begin
        verbose && next!(prog)
        return nothing
    end
    ret = _fva!(opm; ridxs, oniter = [_upprog, oniter])
    verbose && (finish!(prog); flush(stdout); flush(stderr))
    return ret
end

# ------------------------------------------------------------------
export fva_th
function fva_th(net::MetNet, jump_args...;
        ridxs = eachindex(reactions(net)),
        verbose = false,
        oniter = nothing,
        opmodel_kwargs...
    )

    nths = nthreads()
    
    # models pool
    opm_pool = [ 
        FBAFluxOpModel(net, jump_args...; opmodel_kwargs...)
        for _ in 1:nths
    ]
    
    nths = nthreads()
    ridxs = rxnindex(net, ridxs)

    # bounds
    fvalb = lb(net, ridxs) |> copy
    fvaub = ub(net, ridxs) |> copy

    # verbose
    bal = zeros(Int, nths)
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t$nths)  "))
    _upprog = (opm) -> begin
        verbose && next!(prog; showvalues = [(:th, threadid()), (:load, bal)])
        return nothing
    end
    
    ch = chunkedChannel(ridxs; 
        nchnks = 2*nths
    )

    @threads for _ in 1:2*nths
        th = threadid()
        for chk in ch
            
            bal[th] += 1

            opm = opm_pool[th]
            _ridxs = collect(chk)
            _lbs, _ubs = _fva!(opm; 
                ridxs = _ridxs,
                oniter = [_upprog, oniter]
            )
            _setindex!(fvalb, _ridxs, _lbs)
            _setindex!(fvaub, _ridxs, _ubs)
        end
    end
    verbose && (finish!(prog); flush(stdout); flush(stderr))

    return fvalb, fvaub
end 

# ------------------------------------------------------------------
export fva
function fva(net::MetNet, jump_args...;
        th = false,
        ridxs = eachindex(reactions(net)), 
        verbose = false,
        oniter = nothing,
        opmodel_kwargs...
    )
    if th
        return fva_th(net, jump_args...; ridxs, verbose, oniter, opmodel_kwargs...)
    else
        opm = FBAFluxOpModel(net, jump_args...; opmodel_kwargs...)
        return fva!(opm; ridxs, verbose, oniter)
    end
end