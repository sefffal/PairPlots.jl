module MCMCChainsExt
using PairPlots
using MCMCChains


"""
    Series(chain::MCMCChains, kwargs...)

Convenience constructor to build a Series from an abstract matrix.
The columns are named accordingly to the axes of the Matrix (usually :1 though N).
"""
function PairPlots.Series(chains::MCMCChains.Chains;fullgrid=false,bottomleft=true,topright=fullgrid,bins=Dict{Symbol,Any}(), label=nothing, kwargs...)

    chains_parameters = MCMCChains.get_sections(chains, :parameters)
    column_labels = keys(chains_parameters)

    table = NamedTuple([
        collabel => vec(chains_parameters[collabel].data)
        for collabel in column_labels
    ])
    PairPlots.Series(label, table, bottomleft, topright, bins, kwargs)

end
end
