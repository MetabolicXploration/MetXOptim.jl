let
    println()
    println("="^60)
    println("ECHELONIZE")
    println("."^60)
    println()

    # fba
    net0 = pull_net("ecoli_core")
    lep0 = lepmodel(net0)
    biom_ider = extras(net0, "BIOM")
    rxns0 = reactions(net0)
    
    elep = EchelonLEPModel(lep0)
    lep1 = lepmodel(elep)

    sol0 = fba(net0, TESTS_LINSOLVER)
    biom0 = solution(sol0, biom_ider)
    flxs0 = solution(sol0, rxns0)
    @show biom0
    sol1 = fba(lep1, TESTS_LINSOLVER)
    biom1 = solution(sol1, biom_ider)
    flxs1 = solution(sol1, rxns0)
    @show biom1
    @test all(isapprox.(flxs0, flxs1; atol = 1e-8))

    println()

    # Test free box
    fvalb0, fvaub0 = fva(lep1, TESTS_LINSOLVER; verbose = false)

    idxf, idxd = elep.idxf, elep.idxd
    Nf, Nd = length(idxf), length(idxd)
    S = lep1.S[:, [idxd; idxf]]
    G = S[:, (Nd + 1):end]
    b = lep1.b[sortperm(idxd)]
    
    lbf, ubf = fvalb0[idxf], fvaub0[idxf]
    rangef = (ubf .- lbf)
    @time for t in 1:Int(1e5)
        vf = (t == 1) ? lbf : # test extreme
             (t == 2) ? ubf : # test extreme
                lbf .+ rand(Nf) .* rangef # test random
        vd = b - G * vf
        v = [vd; vf]
        @test isapprox(S * v, b; atol = 1e-8)
    end

end