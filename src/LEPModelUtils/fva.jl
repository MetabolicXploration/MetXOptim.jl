# ------------------------------------------------------------------
# TODO: create the OpModel threaded version
export fva_th
function fva_th(lep::LEPModel, solver, ridxs = eachindex(colids(lep));
        verbose = false,
        nths = nthreads(),
        oniter = nothing,
        opmodel_kwargs...
    )
    
    # models pool
    opm_pool = Dict{Int, OpModel}()
    
    ridxs = colindex(lep, ridxs)

    # bounds
    fvalb = lb(lep, ridxs) |> copy
    fvaub = ub(lep, ridxs) |> copy

    # verbose
    bal = Dict{Int, Int}()
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t$nths)  "))
    _upprog = (opm) -> begin
        verbose && next!(prog; showvalues = [(:th, threadid()), (:load, bal)])
        return nothing
    end
    
    ch = chunkedChannel(ridxs; nchnks = 2*nths)

    @threads for _ in 1:nths
        th = threadid()
        for chk in ch
            
            get!(bal, th, 0)
            bal[th] += 1

            opm = get(opm_pool, th) do 
                FBAOpModel(lep, solver; opmodel_kwargs...)
            end

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
function fva(lep::LEPModel, solver, ridxs = eachindex(colids(lep));
        nths = 1,
        verbose = false,
        oniter = nothing,
        opmodel_kwargs...
    )
    if nths > 1
        return fva_th(lep, solver, ridxs; verbose, nths, oniter, opmodel_kwargs...)
    else
        opm = FBAOpModel(lep, solver; opmodel_kwargs...)
        return fva!(opm, ridxs; verbose, oniter)
    end
end

# LEP interface
fva(model, args...; kwargs...) = fva(lepmodel(model), args...; kwargs...)