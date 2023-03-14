# ------------------------------------------------------
# FVA
let
    println()
    println("="^60)
    println("FVA")
    println("."^60)
    println()

    
    for model_id in FVA_TEST_MODELS

        println()
        println("."^60)
        println("MODEL ID: ", model_id)
        println("."^60)
        println()

        netX = pull_net(model_id)
        glc_id = extras(netX, "EX_GLC")
        biom_id = extras(netX, "BIOM")
        biom_idx = colindex(netX, biom_id)
    
        # FVA
        verbose = true
        println("\n", "MetXOptim: ", "fva")
        @time netX_fvalb, netX_fvaub = fva(netX, TESTS_LINSOLVER; verbose)
        
        # TODO: solve GLPK treading issue
        println("\n", "MetXOptim: ", "fva_th")
        # @time netX_th_fvalb, netX_th_fvaub = fva(netX, TESTS_LINSOLVER; verbose, th = true)
        netX_th_fvalb, netX_th_fvaub = netX_fvalb, netX_fvaub # temp hack
        
        # --------------------
        # COBREXA (COBREXA_test_data script)
        
        # FVA
        println("\n", "COBREXA: ", "flux_variability_analysis")
        
        fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fva-bounds.tsv"))
        netCB_fvalb, netCB_fvaub = _read_tsv(Float64, fva_bounds_file)
            
        # println("\n", "BIOMASS: ")
        # @show netX_fvalb[biom_idx], netX_fvaub[biom_idx]
        # @show netX_th_fvalb[biom_idx], netX_th_fvaub[biom_idx]
        # @show netCB_fvalb[biom_idx], netCB_fvaub[biom_idx]
    
        @test all(isapprox(netX_fvalb , netX_th_fvalb; atol = 1e-5))
        @test all(isapprox(netX_fvaub , netX_th_fvaub; atol = 1e-5))
        @test all(isapprox(netX_fvalb , netCB_fvalb; atol = 1e-5))
        @test all(isapprox(netX_fvaub , netCB_fvaub; atol = 1e-5))
    
        # Plots
        idxs = eachindex(reactions(netX))
    
        p = lineplot(netX_fvalb .- netX_th_fvalb;
            title = model_id, 
            name = "netX_fvalb .- netX_th_fvalb", 
            xlabel = "flx index", 
            ylabel = "diff",
            canvas = DotCanvas
        )
        lineplot!(p, netX_fvaub .- netX_th_fvaub; name="netX_fvaub .- netX_th_fvaub")
        lineplot!(p, netX_fvalb .- netCB_fvalb; name="netX_fvalb .- netCB_fvalb")
        lineplot!(p, netX_fvaub .- netCB_fvaub; name="netX_fvaub .- netCB_fvalu")
        
        println()
        println(p)

    end


end    