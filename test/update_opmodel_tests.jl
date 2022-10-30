# ------------------------------------------------------
# update OpModel
let
    println()
    println("="^60)
    println("UPDATE OPMODEL")
    println("."^60)
    println()

    # globals
    lbs = range(-10.0, -0.5; length = 10)

    p = nothing
    for model_id in ["ecoli_core", "ECC2", "iJR904"]
        
        # MetX
        netX = MetXNetHub.pull_net(model_id)
        glc_id = get_extra(netX, "EX_GLC")
        biom_id = get_extra(netX, "BIOM")

        # FBA model
        opm = FBAFluxOpModel(netX, TESTS_LINSOLVER)
        
        # Test glc vs biom
        netX_biomv = Float64[]
        for lb_ in lbs
            lb!(opm, glc_id, lb_)
            opm = fba!(opm)
            push!(netX_biomv, solution(opm, biom_id))
        end
        

        # COBREXA
        netCB = convert(COBREXA.CoreModel, netX)

        netCB_biomv = Float64[]
        for lb_ in lbs
            COBREXA.change_bound!(netCB, glc_id; lower = lb_)
            sol = COBREXA.flux_balance_analysis_dict(netCB, TESTS_LINSOLVER)
            push!(netCB_biomv, sol[biom_id])
        end
        
        @test all(isapprox.(netX_biomv, netCB_biomv))
        
        # Plots
        if isnothing(p)
            p = lineplot(abs.(lbs), netX_biomv;
                title = "FBA", 
                name = string("MetXOptim: ", model_id),
                xlabel = "glc uptake", 
                ylabel = "biom",
                canvas = DotCanvas
            )
            lineplot!(p, abs.(lbs), netCB_biomv; name = string("COBREXA: ", model_id))
        else
            lineplot!(p, abs.(lbs), netX_biomv; name = string("MetXOptim: ", model_id))
            lineplot!(p, abs.(lbs), netCB_biomv; name = string("COBREXA: ", model_id))
        end

    end
    println(p)
    
end