# ------------------------------------------------------
# FVA
let
    println()
    println("="^60)
    println("FVA")
    println("."^60)
    println()

    for model_id in ["toy_net", "ecoli_core", "ECC2"]

        println()
        println("."^60)
        println("MODEL ID: ", model_id)
        println("."^60)
        println()

        netX = MetXNetHub.pull_net(model_id)
        glc_id = get_extra(netX, "EX_GLC")
        biom_id = get_extra(netX, "BIOM")
        biom_idx = rxnindex(netX, biom_id)
    
        # FVA
        verbose = true
        println("\n", "MetXOptim: ", "fva")
        @time _, netX_fvalb, netX_fvaub = fva(netX, TESTS_LINSOLVER; verbose)
        println("\n", "MetXOptim: ", "fva_th")
        @time _, netX_th_fvalb, netX_th_fvaub = fva(netX, TESTS_LINSOLVER; verbose, bash_len = 10, th = true)
        
        # --------------------
        # COBREXA (LOADED DATA: see fva_COBREXA_test_data script) 
        
        # FVA
        println("\n", "COBREXA: ", "flux_variability_analysis")
        
        fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fva-bounds.tsv"))
        netCB_fvalb, netCB_fvaub = _read_tsv(Float64, fva_bounds_file)
            
        println("\n", "BIOMASS: ")
        @show netX_fvalb[biom_idx], netX_fvaub[biom_idx]
        @show netX_th_fvalb[biom_idx], netX_th_fvaub[biom_idx]
        @show netCB_fvalb[biom_idx], netCB_fvaub[biom_idx]
    
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