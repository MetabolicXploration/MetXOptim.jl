# ------------------------------------------------------
using MetXOptim
using MetXOptim.GLPK
using MetXOptim.MetXBase
# using MetXOptim.MetXGEMs.COBREXA
using MetXOptim.MetXNetHub

# ------------------------------------------------------
# load params
include("../test_setup.jl")
include("../tools.jl")

## ------------------------------------------------------
# update OpModel
let
    println()
    println("="^60)
    println("UPDATE OPMODEL")
    println("."^60)
    println()

    # globals
    lbs = OPMODEL_UPDATE_TEST_LB_RANGE

    for model_id in OPMODEL_UPDATE_TEST_MODELS
        
        # MetX
        netX = pull_net(model_id)
        glc_id = extras(netX, "EX_GLC")
        biom_id = extras(netX, "BIOM")

        # COBREXA
        netCB = convert(COBREXA.CoreModel, netX)

        netCB_biomv = Float64[]
        for lb_ in lbs
            COBREXA.change_bound!(netCB, glc_id; lower = lb_)
            sol = COBREXA.flux_balance_analysis_dict(netCB, TESTS_LINSOLVER;
                modifications = [COBREXA.silence],
            )
            push!(netCB_biomv, sol[biom_id])
        end

        # --------------------
        # SAVE
        _write_tsv(
            string(model_id, "--biom-glc.tsv"),
            netCB_biomv
        )
        
    end
    
end

## ------------------------------------------------------
# FBA
let
    println()
    println("="^60)
    println("SIMPLE FBA")
    println("."^60)
    println()

    # --------------------
    # FBA
    model_id = "ecoli_core"
    netX = pull_net(model_id)
    cxanet = convert(COBREXA.CoreModel, netX)
    
    sol = COBREXA.flux_balance_analysis_vec(cxanet, TESTS_LINSOLVER;
        modifications = [COBREXA.silence],
    )
    
    # --------------------
    # SAVE
    _write_tsv(
        string(model_id, "--fba-sol.tsv"),
        sol
    )
end

## ------------------------------------------------------
# FVA
let
    println()
    println("="^60)
    println("FVA DATA")
    println("."^60)
    println()

    for model_id in FVA_TEST_MODELS

        println()
        println("."^60)
        println("MODEL ID: ", model_id)
        println("."^60)
        println()

        netX = pull_net(model_id)
        glc_id = extras(netX, "EX_GLC")
        biom_id = extras(netX, "BIOM")
        biom_idx = colindex(netX, biom_id)
    
        # --------------------
        # FVA COBREXA
        netCB = convert(COBREXA.CoreModel, netX)
        
        # FVA
        println("\n", "COBREXA: ", "flux_variability_analysis")
        @time CBsol = COBREXA.flux_variability_analysis(
            netCB, TESTS_LINSOLVER;
            modifications = [COBREXA.silence],
            bounds = COBREXA.objective_bounds(0.0)
        )
        
        netCB_fvalb, netCB_fvaub = eachcol(CBsol)
            
        # --------------------
        # SAVE
        _write_tsv(
            string(model_id, "--fva-bounds.tsv"), 
            netCB_fvalb, netCB_fvaub
        )
    end


end    

