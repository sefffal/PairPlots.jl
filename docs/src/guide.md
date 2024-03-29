# Guide


This guide demonstrates the usage of PairPlots and shows several ways you can customize it to your liking.

Set up:

::: tabs

== julia
```@example 1
using CairoMakie
using PairPlots
using DataFrames
```
CairoMakie is great for making high quality static figures. Try GLMakie or WGLMakie for interactive plots!

We will use DataFrames here to wrap our tables and provide pleasant table listings. You can use any Tables.jl compatible source, including simple named tuples of vectors for each column.

== python
```python
import numpy as np
import pandas as pd
import pairplots
```
:::


## Single Series

Let's create a basic table of data to visualize.

::: tabs

== julia
```@example 1
N = 100_000
α = [2randn(N÷2) .+ 6; randn(N÷2)]
β = [3randn(N÷2); 2randn(N÷2)]
γ = randn(N)
δ = β .+ 0.6randn(N)

df = DataFrame(;α, β, γ, δ)
df[1:8,:] # hide
```

== python
```python
N = 100000
alpha = np.append([2*np.random.randn(N//2) + 6], [np.random.randn(N//2)])
beta = np.append([3*np.random.randn(N//2)], [2*np.random.randn(N//2)])
gamma = np.random.randn(N)
delta = beta + 0.6*np.random.randn(N)

df = pd.DataFrame({
    'α': alpha,
    'β': beta,
    'γ': gamma,
    'δ': delta
})
```

:::

```
8×4 DataFrame
 Row │ α        β          γ          δ          
     │ Float64  Float64    Float64    Float64    
─────┼───────────────────────────────────────────
   1 │ 5.86784   0.676737   0.814249   0.6119
   2 │ 5.20739  -2.95597   -1.70925   -3.11213
   3 │ 5.58472   3.68555    1.82031    3.60586
   4 │ 4.47898  -0.493841  -0.565474  -0.0699526
   5 │ 8.39713  -2.13249   -1.55868   -1.81314
   6 │ 5.30462  -4.24237    1.34437   -5.15687
   7 │ 8.3575   -0.979077   2.84214   -1.66862
   8 │ 6.20314   2.20745   -0.621868   2.07445
```


We can plot this data directly using `pairplot`, and add customizations iteratively.

::: tabs

== julia

```julia
pairplot(df)
```

== python

```python
pairplots.pairplot(df)
```

:::

```@example 1
pairplot(df) # hide
```

We can display a full grid of plots if we want:

::: tabs

== julia

```julia
pairplot(df, fullgrid=true)
```

== python

```python
pairplots.pairplot(df, fullgrid=True)
```

:::

```@example 1
pairplot(df, fullgrid=true) # hide
```


Override the axis labels:

::: tabs

== julia

```@example 1
pairplot(df, labels = Dict(
    # basic string
    :α => "parameter 1",
    # Makie rich text
    :β => rich("parameter 2", font=:bold, color=:blue),
    # LaTeX String
    :γ => L"\frac{a}{b}",
))
save("ex3.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(df,  labels = {
    # basic string
    'α': "parameter 1",
    # Makie rich text
    'β': pairplots.rich("parameter 2", font='bold', color='blue'),
    # LaTeX String
    'γ': pairplots.latex(r"\frac{a}{b}"),
})
```

:::

![](ex3.png)


Let's move onto more complex examples. The full syntax of the `pairplot` function is:


::: tabs

== julia

```julia
pairplot(
    PairPlots.Series(data) => (::PairPlots.VizType...),
)
```

== python

```python
pairplots.pairplot(
    pairplots.series(data) => (pairplots.viztype1, pairplots.viztype2, ...),
)
```

That is, it accepts a list of pairs of "series objects" and a tuple of "visualization layers". As we'll see later on, you can pass keyword arguments with a series, or a specific visualization layer to customize their behaviour and appearance.
If you don't need to adjust any parameters for a whole series, you can just pass in a data source and PairPlots will wrap it for you:

::: tabs

== julia

```julia
pairplot(
    data => (::PairPlots.VizType...),
)
```

== python

```python
pairplots.pairplot(
    data => (pairplots.viztype1, pairplots.viztype2, ...),
)
```

Let's see how this works by iteratively building up the default visualization.

First, create a basic histogram plot:

::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Hist(),) # note the comma
)
save("ex4.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Hist(),)) # note the comma
)
```

:::

![](ex4.png)


!!! note
    A tuple or list of visualization types is required, even if you just want one. Make sure to include the comma in these examples.

Or, a histogram with hexagonal binning:

::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.HexBin(),)
)
save("ex5.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.HexBin(),))
)
```

:::

![](ex5.png)

Scatter plots:


::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Scatter(),)
)
save("ex6.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Scatter(),))
)
```

:::

![](ex6.png)


Filled contour plots:

::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Contourf(),)
)
save("ex7.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Contourf(),))
)
```

:::

![](ex7.png)

Outlined contour plots:

::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Contour(),)
)
save("ex8.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Contour(),))
)
```

:::

![](ex8.png)

Now let's combine a few plot types. 
Scatter and contours:
```@example 1
pairplot(
    df => (PairPlots.Scatter(), PairPlots.Contour())
)
```


::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Scatter(), PairPlots.Contour())
)
save("ex9.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Scatter(), pairPlots.Contour()))
)
```

:::

![](ex9.png)


Scatter and contours, but hiding points above $2\sigma$:

::: tabs

== julia

```@example 1
pairplot(
    df => (PairPlots.Scatter(filtersigma=2), PairPlots.Contour())
)
save("ex10.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (pairplots.Scatter(filtersigma=2), pairPlots.Contour()))
)
```

:::

![](ex10.png)



Placing a HexBin series underneath:

::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black)
    )
)
save("ex11.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black')

    ))
)
```

:::

![](ex11.png)


### Margin plots

We can add additional visualization layers to the diagonals of the plots using the same syntax.

::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginDensity()
    )
)
save("ex12.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        # New:
        pairplots.MarginDensity()

    ))
)
```

:::

![](ex12.png)

Adjust margin density KDE bandwidth (note: this multiplies the default bandwidth. A value larger than 1 increases smoothing, less than 1 decreases smoothing).

::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginDensity(bandwidth=0.1)
    )
)
save("ex13.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        # New:
        pairplots.MarginDensity(bandwidth=0.1)

    ))
)
```

:::

![](ex13.png)


Adding a histgoram instead of a smoothed kernel density estimate:


::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginHist()
    )
)
save("ex14.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        # New:
        pairplots.MarginHist()

    ))
)
```

:::

![](ex14.png)


Add credible/confidence limits (see the documentation for MarginConfidenceLimits to see how to change the quantiles):



::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginHist(),
        PairPlots.MarginConfidenceLimits(),
    )
)
save("ex15.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        # New:
        pairplots.MarginHist(),
        pairplots.MarginConfidenceLimits(),
    ))
)
```

:::

![](ex15.png)



## Truth Lines
You can quickly add lines to mark particular values of each variable on all subplots using `Truth`:

::: tabs

== julia

```@example 1
pairplot(
    df,
    PairPlots.Truth(
        (;
            α = [0, 6],
            β = 0,
            γ = 0,
            δ = [-1, 0, +1],
        ),
        label="Mean Values"
    )
)
save("ex16.png", ans); # hide
nothing # hide

```

== python

```python
pairplots.pairplot(
    df,
    pairplots.Truth(
        {
            'α': [0, 6],
            'β': 0,
            'γ': 0,
            'δ': [-1, 0, +1],
        },
        label="Mean Values"
    )
)
```
:::

![](ex16.png)

## Trend Lines
You can quickly add a linear trend line to each pair of variables by passing 
a trend-line series:



::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.Scatter(),
        PairPlots.MarginHist(),
        PairPlots.TrendLine(color=:red), # default is red
    ),
    fullgrid=true
)
save("ex17.png", ans); # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.Scatter(),
        pairplots.MarginHist(),
        pairplots.TrendLine(color='red'), # default is red
    )),
    fullgrid=True
)
```
:::

![](ex17.png)

## Correlation
You can add a calculated correlation value between every pair of variables
by passing `PairPlots.Correlation()`.
You can customize the number of digits and the position of the text.


::: tabs

== julia

```@example 1
pairplot(
    df => (
        PairPlots.Scatter(),
        PairPlots.MarginHist(),
        PairPlots.TrendLine(color=:red), # default is red
        PairPlots.Correlation()
    ),
    fullgrid=true
)
save("ex18.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (df, (
        pairplots.Scatter(),
        pairplots.MarginHist(),
        pairplots.TrendLine(color='red'), # default is red
        pairplots.Correlation()
    )),
    fullgrid=True
)
```
:::

![](ex18.png)

`PairPlots.Correlation()` is an alias for `PairPlots.Calculation(StatsBase.cov)`. Feel free to pass any function that accepts two AbstractVectors and calculates a number:
```@example 1
using StatsBase
pairplot(
    df => (
        PairPlots.Scatter(),
        PairPlots.MarginHist(),
        PairPlots.TrendLine(),
        PairPlots.Calculation(
            corkendall,
            color=:blue,
            position=Makie.Point2f(0.2, 0.1)
        )
    ),
)
```

## Customize Axes
You can customize the axes of the subplots freely in two ways. For these examples,
we'll create a variable that is log-normally distributed.

::: tabs

== julia

```@example 1
dfln = DataFrame(;α, β, γ=10 .^ γ, δ)
nothing # hide
```

== python

```python
dfln = pd.DataFrame({
    'α': alpha,
    'β': beta,
    'γ': 10**gamma,
    'δ': delta
})
```

:::

First, you can pass axis parameters for all plots along the diagonal using the `diagaxis` keyword or all plots below the diagonal using the `bodyaxis` parameter.

Turn on grid lines for the body axes:

::: tabs

== julia

```@example 1
pairplot(dfln, bodyaxis=(;xgridvisible=true, ygridvisible=true))
save("ex20.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(dfln, bodyaxis={'xgridvisible':True, 'ygridvisible':True})
```

:::

![](ex20.png)

Apply a pseduo-log scale on the margin plots along the diagonal:

::: tabs

== julia

```@example 1
pairplot(dfln, diagaxis=(;yscale=Makie.pseudolog10, ygridvisible=true))
save("ex21.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(dfln, diagaxis={'yscale':pairplots.Makie.pseudolog10, 'ygridvisible':True})
```

:::

![](ex21.png)


The second way you can control the axes is by table column. This allows you to customize how an individual variable is presented across the pair plot.

For example, we can apply a log scale to all axes that the `γ` variable is plotted against:

::: tabs

== julia

```@example 1
pairplot(
    dfln => (PairPlots.Scatter(), PairPlots.MarginStepHist()),
    axis=(;
        γ=(;
            scale=log10
        )
    )
)
save("ex22.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (dfln, (pairplots.Scatter(), pairplots.MarginStepHist())),
    axis={
        'γ':{
            'scale':pairplots.Makie.log10
        }
    }
)
```

:::

![](ex22.png)



!!! note
    Do not prefix the attribute with `x` or `y`. PairPlots.jl will add the correct prefix as needed.

!!! warning
    Log scale variables usually work best with Scatter series. Histogram and contour based series sometimes extend past zero, breaking the scale.

There is also special support for setting the axis limits of each variable.
The following applies the correct limits either to the vertical axis or horizontal axis as appropriate.
Note that the parameters `low` and/or `high` must be passed as a named tuple.

::: tabs 

== julia

```@example 1
pairplot(
    dfln => (PairPlots.Scatter(), PairPlots.MarginStepHist()),
    axis=(;
        α=(;
            lims=(;low=-10, high=+10)
        ),
        γ=(;
            scale=log10
        )
    )
)
save("ex23.png", ans) # hide
nothing # hide
```

==python

```python
 pairplots.pairplot_interactive(
    (dfln, (pairplots.Scatter(), pairplots.MarginStepHist())),
    axis={
        'α':{
            pairplots.jl.Symbol('lims'):{pairplots.jl.Symbol('low'):-10, pairplots.jl.Symbol('high'):+10}
        },
        'γ':{
            'scale':pairplots.Makie.log10
        }
    }
)
```

:::

![](ex23.png)

## Adding a title

::: tabs

== julia

```@example 1
fig = pairplot(df)
Label(fig[0,:], "This is the title!")
save("ex24.png", fig) # hide
fig
nothing # hide
```

==python

```python
fig = pairplots.pairplot(df)
pairplots.Makie.Label(
    # Row 0 of figure, column 1
    fig[0,1],
    "This is the title!"
)
fig
```

:::

![](ex24.png)

## Layouts
The `pairplot` function integrates easily within larger Makie Figures.

!!! note
    This functionality is not directly exposed to Python, but is available through the `pairplots.Makie` submodule.

Customizing the figure:
```@example 1
fig = Figure(size=(400,400))
pairplot(fig[1,1], df => (PairPlots.Contourf(),))
fig
```

!!! note
    If you only need to pass arguments to `Figure`, for convenience you can use `pairplot(df, figure=(;...))`.


You can plot into one part of a larger figure:

```@example 1
fig = Figure(size=(800,800))

scatterlines(fig[1,1], randn(40))

pairplot(fig[1,2], df)

lines(fig[2,:], randn(200))


colsize!(fig.layout, 2, 450)
rowsize!(fig.layout, 1, 450)

fig

```

Adjust the spacing between axes inside a pair plot:

```@example 1
fig = Figure(size=(600,600))

# Pair Plots must go into a Makie GridLayout. If you pass a GridPosition instead,
# PairPlots will create one for you.
# We can then adjust the spacing within that GridLayout.

gs = GridLayout(fig[1,1])
pairplot(gs, df)

rowgap!(gs, 0)
colgap!(gs, 0)

fig
```


## Multiple Series

You can plot multiple series by simply passing more than one table to `pairplot`
They don't have to have all the same column names.

::: tabs

== julia

```@example 1
# The simplest table format is just a named tuple of vectors.
# You can also pass a DataFrame, or any other Tables.jl compatible object.
table1 = (;
    x = randn(10000),
    y = randn(10000),
)

table2 = (;
    x = 1 .+ randn(10000),
    y = 2 .+ randn(10000),
    z = randn(10000),
)

pairplot(table1, table2)
save("ex25.png", ans) # hide
nothing # hide
```

== python

```python
table1 = pd.DataFrame({
    'x': np.random.randn(10000),
    'y': np.random.randn(10000),
})

table2 = pd.DataFrame({
    'x': 1 + np.random.randn(10000),
    'y': 2 + np.random.randn(10000),
    'z': np.random.randn(10000),
})

pairplots.pairplot(table1, table2)
```

:::

![](ex25.png)

You may want to add a legend:

::: tabs

== julia

```@example 1
c1 = Makie.wong_colors(0.5)[3]
c2 = Makie.wong_colors(0.5)[4]
pairplot(
    PairPlots.Series(table1, label="table 1", color=c1, strokecolor=c1),
    PairPlots.Series(table2, label="table 2", color=c2, strokecolor=c2),
)
save("ex26.png", ans) # hide
nothing # hide
```

== python

```python
c1 = pairplots.Makie.wong_colors(0.5)[2]
c2 = pairplots.Makie.wong_colors(0.5)[3]
pairplots.pairplot(
    pairplots.series(table1, label="table 1", color=c1, strokecolor=c1),
    pairplots.series(table2, label="table 2", color=c2, strokecolor=c2),
)
```

:::

![](ex26.png)


You can customize each series independently if you wish.

::: tabs

== julia

```@example 1
pairplot(
    table2 => (PairPlots.HexBin(colormap=:magma), PairPlots.MarginDensity(color=:orange),  PairPlots.MarginConfidenceLimits(color=:black)),
    table1 => (PairPlots.Contour(color=:cyan, strokewidth=5),),
)
save("ex27.png", ans) # hide
nothing # hide
```

== python

```python
pairplots.pairplot(
    (table2, (
        pairplots.HexBin(colormap='magma'),
        pairplots.MarginDensity(color='orange'),
        pairplots.MarginConfidenceLimits(color='black')
    )),
    (table1, (
        pairplots.Contour(color='cyan', strokewidth=5),)
    ),
)
```

:::

![](ex27.png)
