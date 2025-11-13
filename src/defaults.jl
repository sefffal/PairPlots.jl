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
        linewidth=1.5f0,
    ),
    PairPlots.MarginQuantileText(color=:black,font=:regular),
    PairPlots.MarginQuantileLines(),
)
const multi_series_default_viz = (
    PairPlots.Scatter(filtersigma=2),
    PairPlots.Contour(sigmas=2:2),
    PairPlots.Contourf(alpha=0.6,sigmas=1:1),
    PairPlots.MarginDensity(
        linewidth=2.5f0
    ),
    PairPlots.MarginQuantileText(font=:bold),
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

const bands_default_viz = (
	PairPlots.MarginBands(),
    PairPlots.BodyBands()
)
