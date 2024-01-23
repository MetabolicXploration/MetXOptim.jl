## ------------------------------------------------------------------
# TODO: Rename to LEPOpModel
function FBAOpModel(lep::LEPModel, solver; 
        add_extras!::Function = (opm) -> nothing
    )

    opm = FBAOpModel(
        lep.S, lep.b, 
        lep.lb, lep.ub, lep.c, 
        solver
    )

    # cache lep specific stuff
    extras!(opm, :colids, colids(lep))
    extras!(opm, :rowids, rowids(lep))

    # custom estras
    add_extras!(opm)
    
    # register lin obj
    set_linear_obj!(opm, lep.c)
    
    return opm
end

# Default for lep interfaced objects
FBAOpModel(model, solver; kwargs...) = FBAOpModel(lepmodel(model), solver; kwargs...)

## ------------------------------------------------------------------
# opt call
function fba(model, solver; kwargs...)
    opm = FBAOpModel(model, solver; kwargs...)
    optimize!(opm)
    return opm
end
