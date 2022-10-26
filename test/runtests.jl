using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXOptim
using MetXNetHub

import GLPK, Clp, Ipopt
import MetXBase: COBREXA

@testset "MetXOptim.jl" begin
    
    # ------------------------------------------------------
    # Base
    let
        println()
        println("="^60)
        println("BASE")
        println("."^60)
        println()

        net = MetXNetHub.pull_net("ecoli_core")
        opmodel = MetXOptim.FBAFluxOpModel(net, GLPK.Optimizer; 
            netfields = fieldnames(typeof(net))
        ) 
    
        @test all(metabolites(net, metabolites(net)) .== metabolites(opmodel, metabolites(opmodel)))
        @test all(balance(net, metabolites(net)) .== balance(opmodel, metabolites(opmodel)))
        @test all(reactions(net, reactions(net)) .== reactions(opmodel, reactions(opmodel)))
        @test all(lb(net, reactions(net)) .== lb(opmodel, reactions(opmodel)))
        @test all(ub(net, reactions(net)) .== ub(opmodel, reactions(opmodel)))
        @test all(bounds(net, reactions(net)) .== bounds(opmodel, reactions(opmodel)))
        @test all(genes(net, genes(net)) .== genes(opmodel, genes(opmodel)))
    end

    # ------------------------------------------------------
    # FBA
    let
        println()
        println("="^60)
        println("SIMPLE FBA")
        println("."^60)
        println()

        netX = MetXNetHub.pull_net("ecoli_core")
        opm = fba(netX, GLPK.Optimizer)
        sol0 = solution(opm)
        
        cxanet = convert(COBREXA.CoreModel, netX)
        sol1 = COBREXA.flux_balance_analysis_vec(cxanet, GLPK.Optimizer)

        @test all(isapprox.(sol0, sol1))
    end

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
    
        # MetX
        model_id = "ecoli_core"
        netX = MetXNetHub.pull_net(model_id)
        glc_id = "EX_glc__D_e"
        biom_id = "BIOMASS_Ecoli_core_w_GAM"
    
        # FBA model
        opm = FBAFluxOpModel(netX, GLPK.Optimizer)
        
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
            sol = COBREXA.flux_balance_analysis_dict(netCB, GLPK.Optimizer)
            push!(netCB_biomv, sol[biom_id])
        end
    
        # Plots
        p = lineplot(abs.(lbs), netX_biomv;
            title = model_id, 
            name = "MetXOptim", 
            xlabel = "glc uptake", 
            ylabel = "biom",
            canvas = DotCanvas
        )
        lineplot!(p, abs.(lbs), netCB_biomv; name="COBREXA")
        println(p)
        
        @test all(isapprox.(netX_biomv, netCB_biomv))
    end
    
    # ------------------------------------------------------
    # FVA
    let
        println()
        println("="^60)
        println("FVA")
        println("."^60)
        println()
    
        # --------------------
        # MetX
        model_id = "ecoli_core"
        netX = MetXNetHub.pull_net(model_id)
        glc_id = "EX_glc__D_e"
        biom_id = "BIOMASS_Ecoli_core_w_GAM"
        biom_idx = rxnindex(netX, biom_id)
    
        # FVA
        verbose = true
        println("\n", "MetXOptim: ", "fva")
        @time _, netX_fvalb, netX_fvaub = fva(netX, Ipopt.Optimizer; verbose)
        println("\n", "MetXOptim: ", "fva_th")
        @time _, netX_th_fvalb, netX_th_fvaub = fva(netX, Ipopt.Optimizer; verbose, th = true)
        
        # --------------------
        # COBREXA
        netCB = convert(COBREXA.CoreModel, netX)
        
        # FVA
        println("\n", "COBREXA: ", "flux_variability_analysis")
        @time CBsol = COBREXA.flux_variability_analysis(
            netCB, Ipopt.Optimizer;
            modifications = [COBREXA.silence],
            bounds = COBREXA.objective_bounds(0.0)
            )
            
            netCB_fvalb, netCB_fvaub = eachcol(CBsol)
            
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
