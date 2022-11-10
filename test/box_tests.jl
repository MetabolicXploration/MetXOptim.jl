# Box tests
let

    println()
    println("="^60)
    println("BOXING")
    println("."^60)
    println()

    verbose = true

    model_id = "ECC2"
    # model_id = "ecoli_core"
    net1 = MetXNetHub.pull_net(model_id)
    glc_ex = extras(net1, "EX_GLC")
    biom_id = extras(net1, "BIOM")
    
    # box
    println()
    net2 = box(net1, TESTS_LINSOLVER; 
        verbose, protect_obj = true
    )

    sol1 = solution(fba(net1, TESTS_LINSOLVER), biom_id)
    sol2 = solution(fba(net2, TESTS_LINSOLVER), biom_id)
    @show sol1
    @show size(net1)
    @show sol2
    @show size(net2)
    
    @test all(size(net1) .>= size(net2))
    @test isapprox(sol1, sol2; atol = 1e-6)

    println()
    
end