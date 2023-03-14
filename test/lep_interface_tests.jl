# ------------------------------------------------------
# Base
let
    println()
    println("="^60)
    println("LEP INTERFACE")
    println("."^60)
    println()

    net = pull_net("ecoli_core")
    lep = lepmodel(net)
    opmodel = MetXOptim.FBAOpModel(lep, TESTS_LINSOLVER) 

    @test all(rowids(lep, rowids(lep)) .== rowids(opmodel, rowids(opmodel)))
    @test all(balance(lep, rowids(lep)) .== balance(opmodel, rowids(opmodel)))
    @test all(colids(lep, colids(lep)) .== colids(opmodel, colids(opmodel)))
    @test all(lb(lep, colids(lep)) .== lb(opmodel, colids(opmodel)))
    @test all(ub(lep, colids(lep)) .== ub(opmodel, colids(opmodel)))
    @test all(bounds(lep, colids(lep)) .== bounds(opmodel, colids(opmodel)))
end