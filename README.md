<img src="https://github.com/sefffal/PairPlots.jl/raw/master/docs/src/assets/logo.png" width=100> 

# PairPlots.jl


*Beautiful and flexible visualizations of high dimensional data*

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://sefffal.github.io/PairPlots.jl/dev/)
![Build status](https://github.com/sefffal/PairPlots.jl/actions/workflows/ci.yml/badge.svg)
[![Package Downloads](https://img.shields.io/badge/dynamic/json?url=http%3A%2F%2Fjuliapkgstats.com%2Fapi%2Fv1%2Fmonthly_downloads%2FPairPlots&query=total_requests&suffix=%2Fmonth&label=Downloads)](http://juliapkgstats.com/pkg/PairPlots)
[![codecov](https://codecov.io/gh/sefffal/PairPlots.jl/branch/master/graph/badge.svg?token=1II9NYRIXT)](https://codecov.io/gh/sefffal/PairPlots.jl)
[![License](https://img.shields.io/github/license/sefffal/PairPlots.jl)](LICENSE)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/P/PairPlots.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)

**See the Python version [here](https://github.com/sefffal/pairplots/)**


This package produces pair plots, otherwise known as corner plots or scatter plot matrices: grids of 1D and 2D histograms that allow you to visualize high dimensional data.

Pair plots are an excellent way to visualize the results of MCMC simulations, but are also a useful way to visualize correlations in general data tables.

Read the documentation here: (https://sefffal.github.io/PairPlots.jl/dev/)

The default styles of this package roughly reproduce the output of the Python library [corner.py](https://corner.readthedocs.io/en/latest/index.html) for a single series, and [chainconsumer.py](https://samreay.github.io/ChainConsumer/usage.html) for multiple series.
If these are not to your tastes, this package is highly configurable.

The current version of PairPlots.jl requires the [Makie](https://makie.juliaplots.org/) plotting library. If instead you prefer to use Plots.jl, you can install the legacy version `0.6` of PairPlots (see [archived documentation here](https://github.com/sefffal/PairPlots.jl/blob/b632abd79c0dfbe7387d44393f4fb5b7f74ac5d8/README.md))

For related functionality, see also: [StatsPlots.cornerplot](https://github.com/JuliaPlots/StatsPlots.jl#corrplot-and-cornerplot) and [CornerPlot.jl](https://github.com/kilianbreathnach/CornerPlot.jl) for the Gadfly plotting library.


## Credits
This package is built on top of the great packages Makie, Contour, KernelDensity, and Tables. The overall inspiration and a few lines of code are taken  from corner.py and chainconsumer.py
