let

    println()
    println("="^60)
    println("LINOBJ DEPENDENCE")
    println("."^60)
    println()

    net = pull_net("ECC2")
    glc_ex = extras(net, "EX_GLC")
    glc_idx = colindex(net, glc_ex)
    biom_id = extras(net, "BIOM")
    biom_idx = colindex(net, biom_id)

    opm = FBAOpModel(net, TESTS_LINSOLVER)
    @time depv = objective_dependence(opm)

    @assert depv[biom_idx] == 1
    @assert depv[glc_idx] == -1

end