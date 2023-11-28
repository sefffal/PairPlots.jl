module PairPlotsDynamicUnitfulExt

using PairPlots
using Unitful
using Makie

# Determine the default (not user-provided) label string for a column of this name 
# and column type.
function PairPlots.default_label_string(name::Symbol, col::AbstractArray{<:Unitful.AbstractQuantity})
    u = unit(first(col))
    for el in col
        if unit(el) != u
            @warn "Mixed units in same column \"$name\"" unit1=u unit2=unit(el)
            return Makie.rich(string(name), " ", Makie.rich("(mixed units)",color=:gray))
            break
        end
    end
    unit_str = "[$u]"
    return Makie.rich(string(name), " ", Makie.rich(unit_str,color=:gray))
end


function PairPlots.ustrip(data::Array{<:Unitful.AbstractQuantity})
    dat = Unitful.ustrip.(data)
    return dat
end


end