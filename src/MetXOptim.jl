# TODO: see threads issue (no all cpu is used)
# TODO: introduce callbacks
module MetXOptim

    using MetXBase
    using MetXNetHub
    using JuMP, Clp, Ipopt, Tulip
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
    include("AbstractOpModelUtils/jump_utils.jl")

    #! include FluxObModelUtils
    include("FluxObModelUtils/base.jl")
    include("FluxObModelUtils/boxing.jl")
    include("FluxObModelUtils/constraints.jl")
    include("FluxObModelUtils/fba.jl")
    include("FluxObModelUtils/fva.jl")
    include("FluxObModelUtils/interfaces.jl")
    include("FluxObModelUtils/linobj_dep.jl")
    include("FluxObModelUtils/objectives.jl")

    #! include FBA


end