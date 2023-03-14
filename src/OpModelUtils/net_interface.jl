# # -------------------------------------------------------------------
# # Fundamentals
# # net data

# import MetXGEMs.metnet
# metnet(opm::OpModel) = extras(opm, :metnet, nothing)

# import MetXGEMs.metabolites
# metabolites(opm::OpModel, ider...) = metabolites(metnet(opm), ider...)

# import MetXGEMs.reactions
# reactions(opm::OpModel, ider...) = reactions(metnet(opm), ider...)

# import MetXGEMs.genes
# genes(opm::OpModel, ider...) = genes(metnet(opm), ider...)

