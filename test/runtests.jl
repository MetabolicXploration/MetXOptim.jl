using Test
using MetXBase
using MetXOptim
using MetXNetHub
using JuMP
using Clp

@testset "MetXOptim.jl" begin
    
    # Base
    include("net_interface_tests.jl")

    # TODO: test LP results against COBREXA methods

    @test true
end
