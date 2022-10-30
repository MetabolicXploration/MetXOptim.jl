using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXOptim
using MetXNetHub

import GLPK, Clp, Tulip
import MetXBase: COBREXA

const TESTS_LINSOLVER = Tulip.Optimizer

@testset "MetXOptim.jl" begin

    include("base_tests.jl")    
    include("update_opmodel_tests.jl")    
    include("fba_tests.jl")    
    include("linobj_dep_tests.jl")    
    include("fva_tests.jl")    
    
    
    
end
