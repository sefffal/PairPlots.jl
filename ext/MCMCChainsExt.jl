module MCMCChainsExt
using PairPlots
using MCMCChains


"""
    Series(chain::MCMCChains, kwargs...)

Convenience constructor to build a Series from an abstract matrix.
The columns are named accordingly to the axes of the Matrix (usually :1 though N).
"""
function PairPlots.Series(chains::MCMCChains.Chains; label=nothing, kwargs...)

    column_labels = keys(chains)

    table = NamedTuple([
        collabel => vec(chains[prop].data)
        for collabel in column_labels
    ])
    Series(label, table, kwargs)
end
end
