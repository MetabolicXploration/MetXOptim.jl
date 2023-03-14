## ------------------------------------------------------------------
function FBAFluxOpModel(lep::LEPModel, solver; 
        add_extras!::Function = (opm) -> nothing
    )

    opm = FBAFluxOpModel(
        lep.S, lep.b, 
        lep.lb, lep.ub, lep.c, 
        solver
    )

    # cache lep specific stuff
    extras!(opm, :colids, colids(lep))
    extras!(opm, :rowids, rowids(lep))

    # custom estras
    add_extras!(opm)
    
    return opm
end

# Default for lep interfaced objects
FBAFluxOpModel(model, solver; kwargs...) = FBAFluxOpModel(lepmodel(model), solver; kwargs...)

## ------------------------------------------------------------------
# opt call
function fba(model, solver; kwargs...)
    opm = FBAFluxOpModel(model, solver; kwargs...)
    optimize!(opm)
    return opm
end
