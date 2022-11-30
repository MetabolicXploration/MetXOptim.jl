function _read_tsv(elT, fn::String)
    rows = []
    for line in  eachline(fn)
        isempty(line) && continue
        dig = split(line, "\t")
        vals = parse.(elT, dig)
        push!(rows, vals)
    end
    
    return rows
end

function _write_tsv(filename::String, dat1::AbstractVector, dats::AbstractVector...)
    # build
    tsv_str = String[]
    push!(tsv_str, join(string.(dat1), "\t"))
    for dat in dats
        push!(tsv_str, join(string.(dat), "\t"))
    end
    tsv_str = join(tsv_str, "\n")
    
    # write
    mkpath(TEST_DATDIR)
    datfile = joinpath(TEST_DATDIR, filename)
    open(datfile, "w") do io
        print(io, tsv_str)
    end
    return filename
end