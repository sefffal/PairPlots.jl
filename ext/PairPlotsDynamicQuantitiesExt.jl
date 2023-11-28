module PairPlotsDynamicQuantitiesExt
using PairPlots
using DynamicQuantities
using Makie

# Determine the default (not user-provided) label string for a column of this name 
# and column type.
function PairPlots.default_label_string(name::Symbol, col::AbstractArray{<:UnionAbstractQuantity})
    unit = dimension(first(col))
    for el in col
        if dimension(el) != unit
            @warn "Mixed dimensions in same column \"$name\"" unit1=unit unit2=dimension(el)
            return Makie.rich(string(name), " ", Makie.rich("(mixed dimensions)",color=:gray))
            break
        end
    end
    unit_str = "[$unit]"
    return Makie.rich(string(name), " ", Makie.rich(unit_str,color=:gray))
end


function PairPlots.ustrip(data::Array{<:UnionAbstractQuantity})
    dat = DynamicQuantities.ustrip.(data)
    return dat
end

end