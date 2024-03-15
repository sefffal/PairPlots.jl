#=
This file defines a few default styles that are selected by PairPlots
when the user has not provided anything.
=#

const single_series_color = Makie.RGBA(0., 0., 0., 0.5)
const single_series_default_viz = (
    PairPlots.HexBin(colormap=Makie.cgrad([:transparent, "#333"])),
    PairPlots.Scatter(filtersigma=2), 
    PairPlots.Contour(linewidth=1.5),
    PairPlots.MarginHist(color=Makie.RGBA(0.4,0.4,0.4,0.15)),
    PairPlots.MarginStepHist(color=Makie.RGBA(0.4,0.4,0.4,0.8)),
    PairPlots.MarginDensity(
        color=:black,
        linewidth=1.5f0
    ),
    PairPlots.MarginConfidenceLimits()
)
const multi_series_default_viz = (
    PairPlots.Scatter(filtersigma=2), 
    PairPlots.Contourf(),
    PairPlots.MarginDensity(
        linewidth=2.5f0
    )
)
const many_series_default_viz = (
    PairPlots.Contour(sigmas=[1]),
    PairPlots.MarginDensity(
        linewidth=2.5f0
    )
)
const truths_default_viz = (
    PairPlots.MarginLines(),
    PairPlots.BodyLines(),
)