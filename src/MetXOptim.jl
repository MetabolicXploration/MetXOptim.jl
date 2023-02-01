# TODO: see threads issue (no all cpu is used)

module MetXOptim

    using MetXBase
    using MetXNetHub
    using JuMP
    using ProgressMeter
    using Base.Threads
    using SparseArrays
    
    import GLPK, Clp, Ipopt, Tulip
    import MetXBase: _setindex!, chunkedChannel, run_callbacks

    #! include .
    
    #! include Types
    include("Types/AbstractOpModel.jl")
    include("Types/FluxOpModel.jl")
    include("Types/ObjFunBox.jl")
    
    #! include Utils
    include("Utils/const.jl")
    include("Utils/jump_utils.jl")

    #! include AbstractOpModelUtils
    include("AbstractOpModelUtils/jump_interface.jl")
    include("AbstractOpModelUtils/jump_utils.jl")
    include("AbstractOpModelUtils/optimize.jl")

    #! include FluxOpModelUtils
    include("FluxOpModelUtils/base.jl")
    include("FluxOpModelUtils/boxing.jl")
    include("FluxOpModelUtils/constraints.jl")
    include("FluxOpModelUtils/dual_prices.jl")
    include("FluxOpModelUtils/fba.jl")
    include("FluxOpModelUtils/fva.jl")
    include("FluxOpModelUtils/interfaces.jl")
    include("FluxOpModelUtils/linobj_dep.jl")
    include("FluxOpModelUtils/objectives.jl")
    include("FluxOpModelUtils/r2_fba.jl")

    #! include MetNetsUtils
    include("MetNetsUtils/fva.jl")
    include("MetNetsUtils/vertexes.jl")


end