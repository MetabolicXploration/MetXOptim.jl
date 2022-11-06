using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXOptim
using MetXNetHub

import GLPK, Clp, Tulip
import MetXBase: COBREXA

import Random
Random.seed!(1234)

const TESTS_LINSOLVER = GLPK.Optimizer
const TEST_DATDIR = joinpath(pkgdir(MetXOptim), "test", "data")

@testset "MetXOptim.jl" begin

    include("tools.jl")

    include("base_tests.jl")    
    include("update_opmodel_tests.jl")    
    include("fba_tests.jl")    
    include("linobj_dep_tests.jl")    
    include("fva_tests.jl")
    include("box_tests.jl")
    
end
