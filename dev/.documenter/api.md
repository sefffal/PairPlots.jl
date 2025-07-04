
# API Documentation {#API-Documentation}
<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.pairplot' href='#PairPlots.pairplot'><span class="jlbinding">PairPlots.pairplot</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
pairplot(inputs...; figure=(;), kwargs...)
```


Convenience method to generate a new Makie figure with resolution (800,800) and then call `pairplot` as usual. Returns the figure.

Example:

```julia
fig = pairplot(table)
```



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>



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



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>



```julia
pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)
```


Convenience function to create a reasonable pair plot given one or more inputs that aren&#39;t full specified. Wraps input tables in PairPlots.Series() with a distinct color specified for each series.

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
        PairPlots.MarginQuantileText()
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



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>



```julia
pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)
```


Main PairPlots function. Create a pair plot by plotting into a grid layout within a Makie figure.

Inputs should be one or more `Pair` of PairPlots.AbstractSeries =&gt; tuple of VizType.

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



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.AbstractSeries' href='#PairPlots.AbstractSeries'><span class="jlbinding">PairPlots.AbstractSeries</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AbstractSeries
```


Represents some kind of series in PairPlots.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Series' href='#PairPlots.Series'><span class="jlbinding">PairPlots.Series</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Series(data; label=nothing, kwargs=...)
```


A data series in PairPlots. Wraps a Tables.jl compatible table. You can optionally pass a label for this series to use in the plot legend. Keyword arguments are forwarded to every plot call for this series.

Examples:

```julia
ser = Series(table; label="series 1", color=:red)
```



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>



```julia
Series(matrix::AbstractMatrix; label=nothing, kwargs...)
```


Convenience constructor to build a Series from an abstract matrix. The columns are named accordingly to the axes of the Matrix (usually :1 though N).


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Truth' href='#PairPlots.Truth'><span class="jlbinding">PairPlots.Truth</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Truth(truths; labels=nothing, kwargs=...)
```


Mark a set of &quot;true&quot; values given by `truths` which should be either a named tuple, Dict, etc that can be indexed by the column name and returns a value or values.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.VizType' href='#PairPlots.VizType'><span class="jlbinding">PairPlots.VizType</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



A type of PairPlots visualization. `VizType` is the supertype for all PairPlots visualization types.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.VizTypeBody' href='#PairPlots.VizTypeBody'><span class="jlbinding">PairPlots.VizTypeBody</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
VizTypeBody <: VizType
```


A type of PairPlots visualization that compares two variables.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.VizTypeDiag' href='#PairPlots.VizTypeDiag'><span class="jlbinding">PairPlots.VizTypeDiag</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
VizTypeDiag <: VizType
```


A type of PairPlots visualization that only shows one variable. Used for the plots along the diagonal.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.HexBin' href='#PairPlots.HexBin'><span class="jlbinding">PairPlots.HexBin</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
HexBin(;kwargs...)
```


Plot two variables against eachother using a Makie Hex Bin series. `kwargs` are forwarded to the plot function and can be used to control the number of bins and the appearance.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Hist' href='#PairPlots.Hist'><span class="jlbinding">PairPlots.Hist</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



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


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Calculation' href='#PairPlots.Calculation'><span class="jlbinding">PairPlots.Calculation</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Calculation(function; digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)
```


Apply a function to a pair of variables and add the result as a text label in the appropriate body subplot. Control the position of the label by passing a different value for `position`. Change the number of digits to round the result by passing `digits=N`. The first and only positional argument is the function to use to calculate the correlation.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.PearsonCorrelation' href='#PairPlots.PearsonCorrelation'><span class="jlbinding">PairPlots.PearsonCorrelation</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
PearsonCorrelation(;digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)
```


Calculate the correlation between two variables and add it as a text label to the plot. This is an alias for `Calculation(StatsBase.cor)`. You can adjust the number of digits, the location of the text, etc. See `Calculation` for more details.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Contour' href='#PairPlots.Contour'><span class="jlbinding">PairPlots.Contour</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Contour(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...)
```


Plot two variables against eachother using a contour plot. The contours cover the area under a Gaussian given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth` when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother contours.

::: tip Note

Contours are calculated using Contour.jl and plotted as a Makie line series.

:::

See also: Contourf


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Contourf' href='#PairPlots.Contourf'><span class="jlbinding">PairPlots.Contourf</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Contourf(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...)
```


Plot two variables against eachother using a filled contour plot. The contours cover the area under a Gaussian given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth` when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother contours.

KernelDensity.jl is used to produce smoother contours.

See also: Contour


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.Scatter' href='#PairPlots.Scatter'><span class="jlbinding">PairPlots.Scatter</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
Scatter(;kwargs...)
```


Plot two variables against eachother using a scatter plot.`kwargs` are forwarded to the plot function and can be used to control the appearance.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.MarginQuantileText' href='#PairPlots.MarginQuantileText'><span class="jlbinding">PairPlots.MarginQuantileText</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
MarginQuantileText(format_string::AbstractString, (0.16,0.5,0.84); kwargs...)
MarginQuantileText(formatter::Base.Callable=margin_confidence_default_formatter, (0.16,0.5,0.84); kwargs...)
```



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.MarginQuantileLines' href='#PairPlots.MarginQuantileLines'><span class="jlbinding">PairPlots.MarginQuantileLines</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
MarginQuantileLines(format_string::AbstractString; kwargs...)
MarginQuantileLines(formatter::Base.Callable=margin_confidence_default_formatter; kwargs...)
```



<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.MarginHist' href='#PairPlots.MarginHist'><span class="jlbinding">PairPlots.MarginHist</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



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


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.MarginStepHist' href='#PairPlots.MarginStepHist'><span class="jlbinding">PairPlots.MarginStepHist</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



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


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='PairPlots.MarginDensity' href='#PairPlots.MarginDensity'><span class="jlbinding">PairPlots.MarginDensity</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
MarginDensity(;kwargs...)
```


Plot the smoothed marginal density of a variable along the diagonal of the grid, using Makie&#39;s `density` function. `kwargs` are forwarded to the plot function and can be used to control the appearance.


<Badge type="info" class="source-link" text="source"><a href="http://github.com/sefffal/PairPlots.jl" target="_blank" rel="noreferrer">source</a></Badge>

</details>

