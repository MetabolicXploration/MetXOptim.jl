# TODO: create a size(opm::OpModel)
function rxn_extrema!(opm::OpModel, ri::Int)
    
    # max
    set_linear_obj!(opm, ri, 1.0)
    optimize!(opm)
    ub = solution(opm, ri)
    
    # max
    set_linear_obj!(opm, ri, -1.0)
    optimize!(opm)
    lb = solution(opm, ri)

    return lb, ub
end

rxn_extrema(opm::OpModel, ridx::Int; T = Float64) = keepobj(() -> rxn_extrema!(opm, ridx; T), opm)

# ------------------------------------------------------------------
function _fva!(opm::OpModel, ridxs; 
        oniter = nothing,
    )

    # ridxs
    ridxs = colindex(opm, ridxs)

    # bounds
    fvalb = lb(opm, ridxs)
    fvaub = ub(opm, ridxs)

    # iterate
    for (bi, ri) in enumerate(ridxs)
        fvalb[bi], fvaub[bi] = rxn_extrema!(opm, ri)
        run_callbacks(oniter, opm)
    end

    # box
    return fvalb, fvaub
end

function fva!(opm::OpModel, ridxs;
        oniter = nothing,
        verbose = true
    )   

    # config
    verbose = config(opm, :verbose, verbose)

    # scalar
    ridxs = colindex(opm, ridxs)
    isa(ridxs, Int) && return rxn_extrema!(opm, ridxs)
    
    verbose && (prog = Progress(length(ridxs); desc = "Doing FVA (-t1)  "))
    _upprog = (opm) -> begin
        verbose && next!(prog)
        return nothing
    end
    ret = _fva!(opm, ridxs; oniter = [_upprog, oniter])
    verbose && (finish!(prog); flush(stdout); flush(stderr))
    return ret
end

fva(opm::OpModel, args...; kwargs...) = keepobj(() -> fva!(opm, args...; kwargs...), opm)

