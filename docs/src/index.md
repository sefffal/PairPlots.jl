# PairPlots.jl
*Beautiful and flexible vizualizations of high dimensional data*

[![GitHub](https://img.shields.io/badge/Code-GitHub-black.svg)](https://github.com/sefffal/PairPlots.jl)
[![Package Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/PairPlots)](https://pkgs.genieframework.com?packages=PairPlots)


This package produces pair plots, otherwise known as corner plots or scatter plot matrices: grids of 1D and 2D histograms that allow you to visualize high dimensional data.

Pair plots are an excellent way to vizualize the results of MCMC simulations, but are also a useful way to vizualize correlations in general data tables.

The default styles of this package roughly reproduce the output of the Python library [corner.py](https://corner.readthedocs.io/en/latest/index.html) for a single series, and [chainconsumer.py](https://samreay.github.io/ChainConsumer/usage.html) for multiple series.
If these are not to your tastes, the package aims to be highly configurable.

The current version of PairPlots.jl requires the [Makie](https://makie.juliaplots.org/) plotting library. If instead you prefer to use Plots.jl, you can install the legacy version `0.6` of PairPlots (see [archived documentation here](https://github.com/sefffal/PairPlots.jl/blob/b632abd79c0dfbe7387d44393f4fb5b7f74ac5d8/README.md))

For related functionality, see also: [StatsPlots.cornerplot](https://github.com/JuliaPlots/StatsPlots.jl#corrplot-and-cornerplot), [GeoStats.cornerplot](https://juliaearth.github.io/GeoStats.jl/stable/plotting.html#cornerplot), and [CornerPlot.jl](https://github.com/kilianbreathnach/CornerPlot.jl) for the Gadfly plotting library.
