let
    println()
    println("="^60)
    println("ECHELONIZE")
    println("."^60)
    println()

    net0 = MetXNetHub.pull_net("ecoli_core")
    biom_ider = get_extra(net0, "BIOM")
    rxns0 = reactions(net0)
    
    net1 = echelonize(net0)

    sol0 = fba(net0, TESTS_LINSOLVER)
    biom0 = solution(sol0, biom_ider)
    flxs0 = solution(sol0, rxns0)
    @show biom0
    sol1 = fba(net1, TESTS_LINSOLVER)
    biom1 = solution(sol1, biom_ider)
    flxs1 = solution(sol1, rxns0)
    @show biom1
    @test all(isapprox.(flxs0, flxs1; atol = 1e-8))
end