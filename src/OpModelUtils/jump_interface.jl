# -------------------------------------------------------------------
# jump
jump(opm::OpModel) = opm.jump
jump(opm::OpModel, arg, args...) = jump(opm.jump, arg, args...)

get_jpvars(opm::OpModel, ider) = get_jpvars(opm)[colindex(opm, ider)]

solution(opm::OpModel) = _solution(opm)
solution(opm::OpModel, ider) = _solution(opm, colindex(opm, ider))

import JuMP.objective_value
objective_value(opm::OpModel) = objective_value(jump(opm))

