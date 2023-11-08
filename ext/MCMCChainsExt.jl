module MCMCChainsExt
using PairPlots
using MCMCChains


"""
    Series(chain::MCMCChains, kwargs...)

Convenience constructor to build a Series from an abstract matrix.
The columns are named accordingly to the axes of the Matrix (usually :1 though N).
"""
function PairPlots.Series(chains::MCMCChains.Chains; label=nothing, kwargs...)

    # To dig out only the `parameters` section without using any
    # non-public we have to do some convoluted steps
    sects = sections(chains)
    i = findfirst(==(:parameters), sects)
    chains_parameters = MCMCChains.get_sections(chains)[i]
    column_labels = keys(chains_parameters)

    table = NamedTuple([
        collabel => vec(chains_parameters[collabel].data)
        for collabel in column_labels
    ])
    PairPlots.Series(label, table, kwargs)

end
end
