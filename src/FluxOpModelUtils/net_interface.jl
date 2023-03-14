# -------------------------------------------------------------------
# Fundamentals
# net data

import MetXGEMs.metnet
metnet(opm::FluxOpModel) = extras(opm, :metnet, nothing)

import MetXGEMs.metabolites
metabolites(opm::FluxOpModel, ider...) = metabolites(metnet(opm), ider...)

import MetXGEMs.reactions
reactions(opm::FluxOpModel, ider...) = reactions(metnet(opm), ider...)

import MetXGEMs.genes
genes(opm::FluxOpModel, ider...) = genes(metnet(opm), ider...)

