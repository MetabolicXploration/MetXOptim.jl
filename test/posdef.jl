let
    println()
    println("="^60)
    println("POSDEF TEST")
    println("."^60)
    println()

    net0 = pull_net("ecoli_core")
    net1 = posdef(net0;
        ignore = (rxn) -> startswith(rxn, "EX_")
    )
    linear_weights!(net1, extras(net0, "BIOM"), 1)

    # FBA test
    opm0 = FBAOpModel(net0, TESTS_LINSOLVER)
    optimize!(opm0)
    @show objective_value(opm0)
    opm1 = FBAOpModel(net1, TESTS_LINSOLVER)
    optimize!(opm1)
    @show objective_value(opm1)

    rxns = intersect(reactions(net0), reactions(net1))
    @test all(
        isapprox.(
            solution(opm0, rxns), solution(opm1, rxns); 
            atol = 1e-2
        )
    )
end