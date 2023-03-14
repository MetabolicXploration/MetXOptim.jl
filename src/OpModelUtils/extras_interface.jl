# -------------------------------------------------------------------
# extras interface
import MetXBase.extras
extras(opm::OpModel)::Dict = opm.extras

# -------------------------------------------------------------------
# config interface
@extras_dict_interface OpModel config
