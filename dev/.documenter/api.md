
# API Documentation {#API-Documentation}
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.pairplot' href='#PairPlots.pairplot'>#</a>&nbsp;<b><u>PairPlots.pairplot</u></b> &mdash; <i>Function</i>.




```julia
pairplot(inputs...; figure=(;), kwargs...)
```


Convenience method to generate a new Makie figure with resolution (800,800) and then call `pairplot` as usual. Returns the figure.

Example:

```julia
fig = pairplot(table)
```



[source](http://github.com/sefffal/PairPlots.jl)



```julia
pairplot(gridpos::Makie.GridPosition, inputs...; kwargs...)
```


Create a pair plot at a given grid position of a Makie figure.

Example

```julia
fig = Figure()
pairplot(fig[2,3], table)
fig
```



[source](http://github.com/sefffal/PairPlots.jl)



```julia
pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)
```


Convenience function to create a reasonable pair plot given  one or more inputs that aren't full specified. Wraps input tables in PairPlots.Series() with a distinct color specified for each series.

Here are the defaults applied for a single data table:

```julia
pairplot(fig[1,1], table) == # approximately the following:
pairplot(
    PairPlots.Series(table, color=Makie.RGBA(0., 0., 0., 0.5)) => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black]),),
        PairPlots.Scatter(filtersigma=2), 
        PairPlots.Contour(),
        PairPlots.MarginDensity(
            color=:transparent,
            color=:black,
            linewidth=1.5f0
        ),
        PairPlots.MarginConfidenceLimits()
    )
)
```


Here are the defaults applied for 2 to 5 data tables:

```julia
pairplot(fig[1,1], table1, table2) == # approximately the following:
pairplot(
    PairPlots.Series(table1, color=Makie.wong_colors(0.5)[1]) => (
        PairPlots.Scatter(filtersigma=2), 
        PairPlots.Contourf(),
        PairPlots.MarginDensity(
            linewidth=2.5f0
        )
    ),
    PairPlots.Series(table2, color=Makie.wong_colors(0.5)[2]) => (
        PairPlots.Scatter(filtersigma=2), 
        PairPlots.Contourf(),
        PairPlots.MarginDensity(
            linewidth=2.5f0
        )
    ),
)
```


For 6 or more tables, the defaults are approximately:

```julia
PairPlots.Series(table1, color=Makie.wong_colors(0.5)[series_i]) => (
    PairPlots.Contour(sigmas=[1]),
    PairPlots.MarginDensity(
        linewidth=2.5f0
    )
)
```



[source](http://github.com/sefffal/PairPlots.jl)



```julia
pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)
```


Main PairPlots function. Create a pair plot by plotting into a grid layout within a Makie figure.

Inputs should be one or more `Pair` of PairPlots.AbstractSeries => tuple of VizType.

Additional arguments:
- labels: customize the axes labels with a Dict of column name (symbol) to string, Makie rich text, or LaTeX string.
  
- diagaxis: customize the Makie.Axis of plots along the diagonal with a named tuple of keyword arguments.
  
- bodyaxis: customize the Makie.Axis of plots under the diagonal with a named tuple of keyword arguments.
  
- axis: customize the axes by parameter using a Dict of column name (symbol) to named tuple of axis settings. `x` and `y` are automatically prepended based on the parameter and subplot.  For global properties, see `diagaxis` and `bodyaxis`.
  
- legend:  additional keyword arguments to the Legend constructor, used if one or more series are labelled. You can of course also create your own Legend and inset it into the Figure for complete control. 
  
- fullgrid: true or false (default). Show duplicate plots above the diagonal to make a full grid.
  

**Examples**

Basic usage:

```julia
table = (;a=randn(1000), b=randn(1000), c=randn(1000))
pairplot(table)
```


Customize labels:

```julia
pairplot(table, labels=Dict(:a=>L"\sum{a^2}"))
```


Use a pseudo log scale for one variable:

```julia
pairplot(table, axis=(; a=(;scale=Makie.pseudolog10) ))
```



[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.AbstractSeries' href='#PairPlots.AbstractSeries'>#</a>&nbsp;<b><u>PairPlots.AbstractSeries</u></b> &mdash; <i>Type</i>.




```julia
AstractSeries
```


Represents some kind of series in PairPlots.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Series' href='#PairPlots.Series'>#</a>&nbsp;<b><u>PairPlots.Series</u></b> &mdash; <i>Type</i>.




```julia
Series(data; label=nothing, kwargs=...)
```


A data series in PairPlots. Wraps a Tables.jl compatible table. You can optionally pass a label for this series to use in the plot legend. Keyword arguments are forwarded to every plot call for this series.

Examples:

```julia
ser = Series(table; label="series 1", color=:red)
```



[source](http://github.com/sefffal/PairPlots.jl)



```julia
Series(matrix::AbstractMatrix; label=nothing, kwargs...)
```


Convenience constructor to build a Series from an abstract matrix. The columns are named accordingly to the axes of the Matrix (usually :1 though N).


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Truth' href='#PairPlots.Truth'>#</a>&nbsp;<b><u>PairPlots.Truth</u></b> &mdash; <i>Type</i>.




```julia
Truth(truths; labels=nothing, kwargs=...)
```


Mark a set of "true" values given by `truths` which should be either a named tuple, Dict, etc that can be indexed by the column name and returns a value or values.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.VizType' href='#PairPlots.VizType'>#</a>&nbsp;<b><u>PairPlots.VizType</u></b> &mdash; <i>Type</i>.




" A type of PairPlots vizualization.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.VizTypeBody' href='#PairPlots.VizTypeBody'>#</a>&nbsp;<b><u>PairPlots.VizTypeBody</u></b> &mdash; <i>Type</i>.




" A type of PairPlots vizualization that compares two variables.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.VizTypeDiag' href='#PairPlots.VizTypeDiag'>#</a>&nbsp;<b><u>PairPlots.VizTypeDiag</u></b> &mdash; <i>Type</i>.




"     VizTypeBody

A type of PairPlots vizualization that only shows one variable. Used  for the plots along the diagonal.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.HexBin' href='#PairPlots.HexBin'>#</a>&nbsp;<b><u>PairPlots.HexBin</u></b> &mdash; <i>Type</i>.




```julia
HexBin(;kwargs...)
```


Plot two variables against eachother using a Makie Hex Bin series. `kwargs` are forwarded to the plot function and can be used to control the number of bins and the appearance.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Hist' href='#PairPlots.Hist'>#</a>&nbsp;<b><u>PairPlots.Hist</u></b> &mdash; <i>Type</i>.




```julia
Hist(;kwargs...)
Hist(histprep_function; kwargs...)
```


Plot two variables against eachother using a 2D histogram heatmap. `kwargs` are forwarded to the plot function and can be used to control the number of bins and the appearance.

::: tip Note

You can optionally pass a function to override how the histogram is calculated. It should have the signature: `prepare_hist(xs, ys, nbins)` and return a vector of horizontal bin centers, vertical bin centers, and a matrix of weights.

::: tip Tip

Your `prepare_hist` function it does not have to obey `nbins`

:::

:::


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Calculation' href='#PairPlots.Calculation'>#</a>&nbsp;<b><u>PairPlots.Calculation</u></b> &mdash; <i>Type</i>.




```julia
Calculation(function; digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)
```


Apply a function to a pair of variables and add the result as a text label in the appropriate body subplot. Control the position of the label by passing a different value for `position`. Change the number of digits to round the result by passing `digits=N`. The first and only positional argument is the function to use to calculate the correlation.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Correlation' href='#PairPlots.Correlation'>#</a>&nbsp;<b><u>PairPlots.Correlation</u></b> &mdash; <i>Function</i>.




```julia
Correlation(;digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)
```


Calculate the correlation between two variabels and add it as a text label to the plot. This is an alias for `Calculation(StatsBase.cor)`.  You can adjust the number of digits, the location of the text, etc. See `Calculation` for more details.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Contour' href='#PairPlots.Contour'>#</a>&nbsp;<b><u>PairPlots.Contour</u></b> &mdash; <i>Type</i>.




```julia
Contour(;sigmas=1:2, bandwidth=1.0, kwargs...)
```


Plot two variables against eachother using a contour plot. The contours cover the area under a Gaussian given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth` when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother  contours.

::: tip Note

Contours are calculated using Contour.jl and plotted as a Makie line series.

:::

See also: Contourf


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Contourf' href='#PairPlots.Contourf'>#</a>&nbsp;<b><u>PairPlots.Contourf</u></b> &mdash; <i>Type</i>.




```julia
Contourf(;sigmas=1:2, bandwidth=1.0, kwargs...)
```


Plot two variables against eachother using a filled contour plot. The contours cover the area under a Gaussian given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth` when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother  contours.

KernelDensity.jl is used to produce smoother contours.

See also: Contour


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.Scatter' href='#PairPlots.Scatter'>#</a>&nbsp;<b><u>PairPlots.Scatter</u></b> &mdash; <i>Type</i>.




```julia
Scatter(;kwargs...)
```


Plot two variables against eachother using a scatter plot.`kwargs` are forwarded to the plot function and can be used to control the appearance.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.MarginConfidenceLimits' href='#PairPlots.MarginConfidenceLimits'>#</a>&nbsp;<b><u>PairPlots.MarginConfidenceLimits</u></b> &mdash; <i>Type</i>.




```julia
MarginConfidenceLimits(format_string::AbstractString; kwargs...)
MarginConfidenceLimits(formatter::Base.Callable=margin_confidence_default_formatter; kwargs...)
```



[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.MarginHist' href='#PairPlots.MarginHist'>#</a>&nbsp;<b><u>PairPlots.MarginHist</u></b> &mdash; <i>Type</i>.




```julia
MarginHist(;kwargs...)
MarginHist(histprep_function; kwargs...)
```


Plot a marginal filled histogram of a single variable along the diagonal of the grid. `kwargs` are forwarded to the plot function and can be used to control the number of bins and the appearance.

::: tip Tip

You can optionally pass a function to override how the histogram is calculated. It should have the signature: `prepare_hist(xs, nbins)` and return a vector of bin centers and a vector of weights.

::: tip Note

Your `prepare_hist` function it does not have to obey `nbins`

:::

:::


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.MarginStepHist' href='#PairPlots.MarginStepHist'>#</a>&nbsp;<b><u>PairPlots.MarginStepHist</u></b> &mdash; <i>Type</i>.




```julia
MarginStepHist(;kwargs...)
MarginStepHist(histprep_function; kwargs...)
```


Plot a marginal histogram without filled columns of a single variable along the diagonal of the grid. `kwargs` are forwarded to the plot function and can be used to control the number of bins and the appearance.

::: tip Tip

You can optionally pass a function to override how the histogram is calculated. It should have the signature: `prepare_hist(xs, nbins)` and return a vector of bin centers and a vector of weights.

::: tip Note

Your `prepare_hist` function it does not have to obey `nbins`

:::

:::


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
<div style='border-width:1px; border-style:solid; border-color:black; padding: 1em; border-radius: 25px;'>
<a id='PairPlots.MarginDensity' href='#PairPlots.MarginDensity'>#</a>&nbsp;<b><u>PairPlots.MarginDensity</u></b> &mdash; <i>Type</i>.




```julia
MarginDensity(;kwargs...)
```


Plot the smoothed marginal density of a variable along the diagonal of the grid, using Makie's `density`  function. `kwargs` are forwarded to the plot function and can be used to control the appearance.


[source](http://github.com/sefffal/PairPlots.jl)

</div>
<br>
