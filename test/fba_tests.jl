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
    
    
    fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fba-sol.tsv"))
    sol1 = _read_tsv(Float64, fva_bounds_file) |> first

    @test all(isapprox.(sol0, sol1))
end