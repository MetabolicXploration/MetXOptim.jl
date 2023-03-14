# ------------------------------------------------------
using MetXOptim
using MetXOptim.GLPK
using MetXOptim.MetXBase
using MetXOptim.MetXGEMs.COBREXA
using MetXOptim.MetXNetHub

# ------------------------------------------------------
const TEST_DATDIR = joinpath(pkgdir(MetXOptim), "test", "data")
const TESTS_LINSOLVER = GLPK.Optimizer

## ------------------------------------------------------
# update OpModel
let
    println()
    println("="^60)
    println("UPDATE OPMODEL")
    println("."^60)
    println()

    # globals
    lbs = range(-10.0, -0.5; length = 10)

    for model_id in ["ecoli_core", "ECC2", "iJR904"]
        
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
        mkpath(TEST_DATDIR)
        tsv_str = string(
            join(netCB_biomv, "\t")
        )
        biom_glc_file = joinpath(TEST_DATDIR, string(model_id, "--biom-glc.tsv"))
        open(biom_glc_file, "w") do io
            print(io, tsv_str)
        end
        
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
    mkpath(TEST_DATDIR)
    tsv_str = string(
        join(sol, "\t")
    )
    fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fba-sol.tsv"))
    open(fva_bounds_file, "w") do io
        print(io, tsv_str)
    end
end

## ------------------------------------------------------
# FVA
let
    println()
    println("="^60)
    println("FVA DATA")
    println("."^60)
    println()

    for model_id in ["toy_net", "ecoli_core", "ECC2"]

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
        mkpath(TEST_DATDIR)
        tsv_str = string(
            join(netCB_fvalb, "\t"), "\n",
            join(netCB_fvaub, "\t"),
        )
        fva_bounds_file = joinpath(TEST_DATDIR, string(model_id, "--fva-bounds.tsv"))
        open(fva_bounds_file, "w") do io
            print(io, tsv_str)
        end
    end


end    