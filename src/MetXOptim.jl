# TODO: see threads issue (no all cpu is used)

module MetXOptim

    using MetXBase
    using MetXBase.MassExport
    using JuMP
    using ProgressMeter
    using Base.Threads
    using SparseArrays

    #! include .
    
    #! include Types
    include("Types/0_AbstractOpModel.jl")
    include("Types/1_OpModel.jl")
    include("Types/2_ObjFunBox.jl")
    
    #! include Utils
    include("Utils/const.jl")
    include("Utils/jump_utils.jl")

    #! include AbstractOpModelUtils
    include("AbstractOpModelUtils/jump_interface.jl")
    include("AbstractOpModelUtils/jump_utils.jl")
    include("AbstractOpModelUtils/optimize.jl")

    #! include OpModelUtils
    include("OpModelUtils/base.jl")
    include("OpModelUtils/boxing.jl")
    include("OpModelUtils/constraints.jl")
    include("OpModelUtils/dual_prices.jl")
    include("OpModelUtils/extras_interface.jl")
    include("OpModelUtils/fba.jl")
    include("OpModelUtils/fva.jl")
    include("OpModelUtils/jump_interface.jl")
    include("OpModelUtils/lep_interface.jl")
    include("OpModelUtils/linobj_dep.jl")
    include("OpModelUtils/net_interface.jl")
    include("OpModelUtils/objectives.jl")

    #! include LEPModelUtils
    include("LEPModelUtils/boxing.jl")
    include("LEPModelUtils/fba.jl")
    include("LEPModelUtils/fva.jl")
    include("LEPModelUtils/r2_fba.jl")
    include("LEPModelUtils/vertexes.jl")

    # exports
    @exportall_non_underscore()

end