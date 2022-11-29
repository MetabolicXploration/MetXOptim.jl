# ------------------------------------------------------
# FBA
let
    println()
    println("="^60)
    println("SIMPLE FBA")
    println("."^60)
    println()

    model_id = "ecoli_core"
    netX = MetXNetHub.pull_net(model_id)
    opm = fba(netX, TESTS_LINSOLVER)
    sol0 = solution(opm)
    
    # COBREXA (COBREXA_test_data script)
    fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fba-sol.tsv"))
    sol1 = _read_tsv(Float64, fva_bounds_file) |> first

    @test all(isapprox.(sol0, sol1; atol = 1e-8))

    # EchelonMetNet
    enet = EchelonMetNet(netX)
    eopm = fba(enet, TESTS_LINSOLVER)

    @test isapprox.(
        solution(eopm, reactions(enet)),
        solution(opm, reactions(enet));
        atol = 1e-8
    ) |> all

end