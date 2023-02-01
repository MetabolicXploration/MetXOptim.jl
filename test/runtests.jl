using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXOptim
using MetXNetHub


## ------------------------------------------------------------------
@testset "MetXOptim.jl" begin

    include("test_setup.jl")
    include("tools.jl")

    include("base_tests.jl")    
    include("update_opmodel_tests.jl")    
    include("fba_tests.jl")    
    include("linobj_dep_tests.jl")    
    include("fva_tests.jl")
    include("box_tests.jl")
    include("echelonize_tests.jl")
    
end
