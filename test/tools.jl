function _read_tsv(elT, fn::String)
    rows = []
    for line in  eachline(fn)
        dig = split(line, "\t")
        vals = parse.(elT, dig)
        push!(rows, vals)
    end
    
    return rows
end