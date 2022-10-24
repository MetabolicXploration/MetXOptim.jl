
import Base.show
show(io::IO, m::FluxOpModel) = print(io, "FluxOpModel(", mets_count(m), ", ", rxns_count(m), ")")

import Base.size
size(m::FluxOpModel) = (mets_count(m), rxns_count(m))
