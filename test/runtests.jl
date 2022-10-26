using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXOptim
using MetXNetHub

import GLPK
import MetXBase: COBREXA

@testset "MetXOptim.jl" begin
    
    # ------------------------------------------------------
    # Base
    let
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
    
    
end
