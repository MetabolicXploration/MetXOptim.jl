function box!(lep::LEPModel, solver; kwargs...) 

    opm = FBAOpModel(lep, solver)
    opm = box!(opm; kwargs...)

    lb!(lep, lb(opm))
    ub!(lep, ub(opm))
    return lep
end

# TODO: new name sug: inscribe!, fullrank_box
function box(lep::LEPModel, solver; 
        reduce = true,
        eps = 0.0, protect = [],
        box_kwargs...
    ) 

    if reduce # empty_fixxed! touch S and b
        lep = deepcopy(lep)
    else
        lep = LEPModel(lep; 
            lb = copy(lb(lep)),
            ub = copy(ub(lep)),
        )
    end
    
    box!(lep, solver; box_kwargs...)
    
    if reduce
        empty_fixxed!(lep; eps, protect)
        lep = emptyless_model(lep)
    end

    return lep
end