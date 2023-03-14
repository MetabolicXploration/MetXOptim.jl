import GLPK, Clp, Tulip
# import MetXGEMs: COBREXA

import Random
Random.seed!(1234)

const TESTS_LINSOLVER = GLPK.Optimizer
const TH_TESTS_LINSOLVER = Clp.Optimizer
const TEST_DATDIR = joinpath(pkgdir(MetXOptim), "test", "data")

const FVA_TEST_MODELS = ["toy_net", "ecoli_core", "ECC2"]

const OPMODEL_UPDATE_TEST_MODELS = ["ecoli_core", "ECC2", "iJR904"]
const OPMODEL_UPDATE_TEST_LB_RANGE = range(-10.0, -0.5; length = 10)