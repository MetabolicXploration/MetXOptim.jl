# activate env
# using RunTestsEnv
# @activate_testenv

using Test
using MetXBase
using MetXBase.UnicodePlots
using MetXGEMs
using MetXOptim
using MetXNetHub
using Statistics


## ------------------------------------------------------------------
@testset "MetXOptim.jl" begin

    include("test_setup.jl")
    include("tools.jl")

    include("lep_interface_tests.jl")
    include("update_opmodel_tests.jl")
    include("fba_tests.jl")
    include("linobj_dep_tests.jl")
    include("fva_tests.jl")
    include("posdef.jl")
    include("box_tests.jl")
    include("echelonize_tests.jl")
end
