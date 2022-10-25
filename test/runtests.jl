using Test
using MetXBase
using MetXOptim
using MetXNetHub

import Clp
import MetXBase: COBREXA

@testset "MetXOptim.jl" begin
    
    # ------------------------------------------------------
    # Base
    let
        net = MetXNetHub.pull_net("ecoli_core")
        opmodel = MetXOptim.FBAFluxOpModel(net, Clp.Optimizer; 
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
        opm = fba(netX, Clp.Optimizer)
        sol0 = solution(opm)
        
        cxanet = convert(COBREXA.CoreModel, netX)
        sol1 = COBREXA.flux_balance_analysis_vec(cxanet, Clp.Optimizer)

        @test all(isapprox.(sol0, sol1))
    end
end
