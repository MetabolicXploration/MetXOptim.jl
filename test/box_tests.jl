# Box tests
let

    println()
    println("="^60)
    println("BOXING")
    println("."^60)
    println()

    verbose = true

    model_id = "ecoli_core"
    net1 = pull_net(model_id)
    lep1 = lepmodel(net1)
    
    glc_ex = extras(net1, "EX_GLC")
    biom_id = extras(net1, "BIOM")
    
    # box
    println()
    lep2 = box(lep1, TESTS_LINSOLVER; 
        verbose, protect_obj = true
    )

    sol1 = solution(fba(lep1, TESTS_LINSOLVER), biom_id)
    sol2 = solution(fba(lep2, TESTS_LINSOLVER), biom_id)
    @show sol1
    @show size(lep1)
    @show sol2
    @show size(lep2)
    
    @test all(size(lep1) .>= size(lep2))
    @test isapprox(sol1, sol2; atol = 1e-6)
    
end