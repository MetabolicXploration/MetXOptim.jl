# -------------------------------------------------------------------
# jump
export jump
jump(opm::FluxOpModel) = opm.jump
jump(opm::FluxOpModel, arg, args...) = jump(opm.jump, arg, args...)

get_jpvars(opm::FluxOpModel, ider) = get_jpvars(opm)[colindex(opm, ider)]

export solution
solution(opm::FluxOpModel) = _solution(opm)
solution(opm::FluxOpModel, ider) = _solution(opm, colindex(opm, ider))

import JuMP.objective_value
export objective_value
objective_value(opm::FluxOpModel) = objective_value(jump(opm))

