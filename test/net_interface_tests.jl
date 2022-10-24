let
    net = MetXNetHub.pull_net("ecoli_core")
    opmodel = MetXOptim.FBAFluxOpModel(net, Clp.Optimizer) 

    @test all(metabolites(net, metabolites(net)) .== metabolites(opmodel, metabolites(opmodel)))
    @test all(balance(net, metabolites(net)) .== balance(opmodel, metabolites(opmodel)))
    @test all(reactions(net, reactions(net)) .== reactions(opmodel, reactions(opmodel)))
    @test all(lb(net, reactions(net)) .== lb(opmodel, reactions(opmodel)))
    @test all(ub(net, reactions(net)) .== ub(opmodel, reactions(opmodel)))
    @test all(bounds(net, reactions(net)) .== bounds(opmodel, reactions(opmodel)))
    @test all(genes(net, genes(net)) .== genes(opmodel, genes(opmodel)))
end