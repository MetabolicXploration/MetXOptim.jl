# -------------------------------------------------------------------
# extras interface
import MetXBase.extras
extras(opm::FluxOpModel)::Dict = opm.extras

# -------------------------------------------------------------------
# config interface
@extras_dict_interface FluxOpModel config
