# ------------------------------------------------------
# update OpModel
let
    println()
    println("="^60)
    println("UPDATE OPMODEL")
    println("."^60)
    println()

    # globals
    lbs = OPMODEL_UPDATE_TEST_LB_RANGE

    p = nothing
    for model_id in OPMODEL_UPDATE_TEST_MODELS
        
        # MetX
        netX = pull_net(model_id)
        glc_id = extras(netX, "EX_GLC")
        biom_id = extras(netX, "BIOM")

        # FBA model
        opm = FBAOpModel(netX, TESTS_LINSOLVER)
        
        # Test glc vs biom
        netX_biomv = Float64[]
        for lb_ in lbs
            lb!(opm, glc_id, lb_)
            opm = optimize!(opm)
            push!(netX_biomv, solution(opm, biom_id))
        end
        

        # COBREXA
        biom_glc_file = joinpath(TEST_DATDIR, string(model_id, "--biom-glc.tsv"))
        netCB_biomv = _read_tsv(Float64, biom_glc_file) |> first
        
        @test isapprox(netX_biomv, netCB_biomv; atol = 1e-8)
        
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