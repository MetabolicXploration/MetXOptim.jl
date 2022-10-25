module MetXOptim

    using MetXBase
    using MetXNetHub
    using JuMP, Clp, Ipopt
    using ProgressMeter
    using Base.Threads
    using SparseArrays

    #! include .
    
    #! include Types
    include("Types/AbstractOpModel.jl")
    include("Types/FluxOpModel.jl")
    
    #! include Utils
    include("Utils/const.jl")

    #! include AbstractOpModelUtils
    include("AbstractOpModelUtils/jump_interface.jl")

    #! include FluxObModelUtils
    include("FluxObModelUtils/base.jl")
    include("FluxObModelUtils/constraints.jl")
    include("FluxObModelUtils/fba.jl")
    include("FluxObModelUtils/interfaces.jl")
    include("FluxObModelUtils/objectives.jl")

    #! include FBA


end