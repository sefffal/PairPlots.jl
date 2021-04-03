# CornerPlots.jl

This package is essentially a clone of the well-known Python library [corner.py](https://corner.readthedocs.io/en/latest/index.html). It is presents a visualization of high dimensional data (presumably sampled using a Monte Carlo method) that includes 1D histograms of each variable.


## Usage
Though this package seeks to approximate the output of `corner.py`, the interface is somewhat more Julian. The only export from this package is the function `corner`. This function has one required argument, a [Tables.jl](https://tables.juliadata.org/stable/) compatible table consisting of two or more columns. This can simply be a named tuple of vectors, a [DataFrame](https://dataframes.juliadata.org/stable/), [TypedTable](https://typedtables.juliadata.org/stable/), result of an execute statement from [SQLLite](https://juliadatabases.org/SQLite.jl/stable/), data loaded from [Arrow](https://arrow.juliadata.org/stable/manual/#Writing-arrow-data), etc.

The variable names are by default taken from the column names of the input table, but can also be supplied by a second vector of strings.

This package uses [RecipesBase](http://juliaplots.org/RecipesBase.jl/stable/) rather than [Plots](http://docs.juliaplots.org/latest/) directly, so you must also load Plots in order to see any output. The package is only tested with [GR](https://github.com/jheinen/GR.jl).

### Basic Example
```julia
using Plots
using CornerPlots

# Generate some data to visualize
a = randn(10000)
b = 2randn(10000)
c = a .+ b
d = a .* b

data = (;a,b,c,d)

corner(data,)

```


## TODO:
- direct support for MCMCChains via requires? or just duck typing
- direct GRUtils backend