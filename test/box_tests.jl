# Box tests
let

    println()
    println("="^60)
    println("BOXING")
    println("."^60)
    println()

    verbose = true

    model_id = "ECC2"
    net0 = pull_net(model_id)
    lep0 = lepmodel(net0)
    @time lep1 = fva_strip(lep0, TH_TESTS_LINSOLVER; nths = 3, verbose)
    @time lep2 = fva_strip(lep0, TH_TESTS_LINSOLVER; nths = 1, verbose)
    
    @test all(size(lep0) .>= size(lep1))
    @test all(size(lep0) .>= size(lep2))
    @test all(size(lep1) .== size(lep2))
    @test isapprox(lb(lep1), lb(lep2); atol = 1e-5)
    @test isapprox(ub(lep1), ub(lep2); atol = 1e-5)
    
    
end