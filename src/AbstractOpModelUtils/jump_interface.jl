# Jump methods and utils to be applicable directly over AbtractOpModels

# Common methods to work with jump models
export jump
jump(jpm::JuMP.Model) = jpm
jump(opm::AbstractOpModel) = error("Method jump(opm::$(typeof(opm))) not defined!")
jump(jpm::JuMP.Model, k) = jpm[k]
jump(jpm::JuMP.Model, k, dfl) = haskey(jpm, k) ? jpm[k] : dfl
jump(opm::AbstractOpModel, k) = error("Method jump(opm::$(typeof(opm)), k) not defined!")

import JuMP.set_optimizer
export set_optimizer
set_optimizer(opm::AbstractOpModel, args...) = set_optimizer(jump(opm), args...)

import JuMP.set_silent
export set_silent
set_silent(opm::AbstractOpModel, args...) = set_silent(jump(opm), args...)

import JuMP.num_variables
export num_variables
num_variables(opm::AbstractOpModel) = JuMP.num_variables(jump(opm))

import JuMP.termination_status
export termination_status
termination_status(opm::AbstractOpModel) = JuMP.termination_status(jump(opm))

import JuMP.normalized_rhs
export normalized_rhs
normalized_rhs(opm::AbstractOpModel, cons_key::Symbol) = JuMP.normalized_rhs.(jump(opm, cons_key))

import JuMP.haskey
haskey(opm::AbstractOpModel, key) = JuMP.haskey(jump(opm), key)
