# ------------------------------------------------------------------
# MetNet
# TODO: create the OpModel threaded version
export fva_th
function fva_th(net::MetNet, solver, ridxs = eachindex(reactions(net));
        verbose = false,
        oniter = nothing,
        opmodel_kwargs...
    )

    nths = nthreads()
    
    # models pool
    opm_pool = [ 
        FBAFluxOpModel(net, solver; opmodel_kwargs...)
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
            _lbs, _ubs = _fva!(opm, _ridxs;
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
function fva(net::MetNet, solver, ridxs = eachindex(reactions(net));
        th = false,
        verbose = false,
        oniter = nothing,
        opmodel_kwargs...
    )
    if th
        return fva_th(net, solver, ridxs; verbose, oniter, opmodel_kwargs...)
    else
        opm = FBAFluxOpModel(net, solver; opmodel_kwargs...)
        return fva!(opm, ridxs; verbose, oniter)
    end
end

# AbstractMetNet
fva(net::AbstractMetNet, args...; kwargs...) = fva(metnet(net), args...; kwargs...)