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
    @test isapprox(flxs0, flxs1; atol = 1e-8)

    println()

    # Test free fva_strip
    fvalb0, fvaub0 = fva(lep1, TH_TESTS_LINSOLVER; verbose = false)

    idxi, idxd = elep.idxi, elep.idxd
    Nf, Nd = length(idxi), length(idxd)
    S = lep1.S[:, [idxd; idxi]]
    G = S[:, (Nd + 1):end]
    b = lep1.b[sortperm(idxd)]
    
    lbf, ubf = fvalb0[idxi], fvaub0[idxi]
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