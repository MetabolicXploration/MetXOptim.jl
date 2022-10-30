# ------------------------------------------------------
# FBA
let
    println()
    println("="^60)
    println("SIMPLE FBA")
    println("."^60)
    println()

    netX = MetXNetHub.pull_net("ecoli_core")
    opm = fba(netX, TESTS_LINSOLVER)
    sol0 = solution(opm)
    
    cxanet = convert(COBREXA.CoreModel, netX)
    sol1 = COBREXA.flux_balance_analysis_vec(cxanet, TESTS_LINSOLVER)

    @test all(isapprox.(sol0, sol1))
end