
# Guide {#Guide}

This guide demonstrates the usage of PairPlots and shows several ways you can customize it to your liking.

Set up:

::: tabs

== julia

```julia
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

## Single Series {#Single-Series}

Let&#39;s create a basic table of data to visualize.

::: tabs

== julia

```julia
N = 100_000
α = [2randn(N÷2) .+ 6; randn(N÷2)]
β = [3randn(N÷2); 2randn(N÷2)]
γ = randn(N)
δ = β .+ 0.6randn(N)

df = DataFrame(;α, β, γ, δ)
```

<div v-html="`&lt;div&gt;&lt;div style = &quot;float: left;&quot;&gt;&lt;span&gt;8×4 DataFrame&lt;/span&gt;&lt;/div&gt;&lt;div style = &quot;clear: both;&quot;&gt;&lt;/div&gt;&lt;/div&gt;&lt;div class = &quot;data-frame&quot; style = &quot;overflow-x: scroll;&quot;&gt;&lt;table class = &quot;data-frame&quot; style = &quot;margin-bottom: 6px;&quot;&gt;&lt;thead&gt;&lt;tr class = &quot;header&quot;&gt;&lt;th class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;Row&lt;/th&gt;&lt;th style = &quot;text-align: left;&quot;&gt;α&lt;/th&gt;&lt;th style = &quot;text-align: left;&quot;&gt;β&lt;/th&gt;&lt;th style = &quot;text-align: left;&quot;&gt;γ&lt;/th&gt;&lt;th style = &quot;text-align: left;&quot;&gt;δ&lt;/th&gt;&lt;/tr&gt;&lt;tr class = &quot;subheader headerLastRow&quot;&gt;&lt;th class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;&lt;/th&gt;&lt;th title = &quot;Float64&quot; style = &quot;text-align: left;&quot;&gt;Float64&lt;/th&gt;&lt;th title = &quot;Float64&quot; style = &quot;text-align: left;&quot;&gt;Float64&lt;/th&gt;&lt;th title = &quot;Float64&quot; style = &quot;text-align: left;&quot;&gt;Float64&lt;/th&gt;&lt;th title = &quot;Float64&quot; style = &quot;text-align: left;&quot;&gt;Float64&lt;/th&gt;&lt;/tr&gt;&lt;/thead&gt;&lt;tbody&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;1&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;7.83641&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-2.43355&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.891984&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-1.90527&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;2&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;3.74596&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;0.27294&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;2.74363&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;0.542859&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;3&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;6.8948&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.88536&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.0785164&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.26595&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;4&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;3.50234&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.16523&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;0.416798&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;0.161719&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;5&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;8.0622&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.474853&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.674965&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.113103&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;6&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;7.66873&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.950188&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.520387&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.498262&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;7&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;9.95283&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.00629&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;-0.398378&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.24&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;&lt;td class = &quot;rowNumber&quot; style = &quot;font-weight: bold; text-align: right;&quot;&gt;8&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;2.80844&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;4.82809&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;1.88084&lt;/td&gt;&lt;td style = &quot;text-align: right;&quot;&gt;4.95681&lt;/td&gt;&lt;/tr&gt;&lt;/tbody&gt;&lt;/table&gt;&lt;/div&gt;`"></div>

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
![](dmpplfh.png){width=757px height=774px}

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
![](vvjejgg.png){width=757px height=774px}

The `fullgrid` option is short for `bottomleft=true` and `topright=true`. We can specify these individually to create a top-right corner plot:

::: tabs

== julia

```julia
pairplot(df, bottomleft=false, topright=true)
```


== python

```python
pairplots.pairplot(df, bottomleft=False, topright=True)
```


:::
![](qxybobj.png){width=747px height=775px}

Override the axis labels:

::: tabs

== julia

```julia
pairplot(df, labels = Dict(
    # basic string
    :α => "parameter 1",
    # Makie rich text
    :β => rich("parameter 2", font=:bold, color=:blue),
    # LaTeX String
    :γ => L"\frac{a}{b}",
))
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


Let&#39;s move onto more complex examples. The full syntax of the `pairplot` function is:

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


That is, it accepts a list of pairs of &quot;series objects&quot; and a tuple of &quot;visualization layers&quot;. As we&#39;ll see later on, you can pass keyword arguments with a series, or a specific visualization layer to customize their behaviour and appearance.

:::

If you don&#39;t need to adjust any parameters for a whole series, you can just pass in a data source and PairPlots will wrap it for you:

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


:::

Let&#39;s see how this works by iteratively building up the default visualization.

First, create a basic histogram plot:

::: tabs

== julia

```julia
pairplot(
    df => (PairPlots.Hist(),) # note the comma
)
```


== python

```python
pairplots.pairplot(
    (df, (pairplots.Hist(),)) # note the comma
)
```


:::


![](ex4.png)


::: tip Note

A tuple or list of visualization types is required, even if you just want one. Make sure to include the comma in these examples.

:::

Or, a histogram with hexagonal binning:

::: tabs

== julia

```julia
pairplot(
    df => (PairPlots.HexBin(),)
)
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

```julia
pairplot(
    df => (PairPlots.Scatter(),)
)
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

```julia
pairplot(
    df => (PairPlots.Contourf(),)
)
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

```julia
pairplot(
    df => (PairPlots.Contour(),)
)
```


== python

```python
pairplots.pairplot(
    (df, (pairplots.Contour(),))
)
```


:::


![](ex8.png)


Now let&#39;s combine a few plot types. Scatter and contours:

```julia
pairplot(
    df => (PairPlots.Scatter(), PairPlots.Contour())
)
```

![](omuuoih.png){width=589px height=585px}

::: tabs

== julia

```julia
pairplot(
    df => (PairPlots.Scatter(), PairPlots.Contour())
)
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

```julia
pairplot(
    df => (PairPlots.Scatter(filtersigma=2), PairPlots.Contour())
)
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

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black)
    )
)
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


### Margin plots {#Margin-plots}

We can add additional visualization layers to the diagonals of the plots using the same syntax.

::: tabs

== julia

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginDensity()
    )
)
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

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginDensity(bandwidth=0.1)
    )
)
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

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        # New:
        PairPlots.MarginHist()
    )
)
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


Add credible/confidence limit titles (see the documentation for MarginQuantileText and MarginQuantileLines to see how to change the quantiles):

::: tabs

== julia

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        PairPlots.MarginHist(),
        # New:
        PairPlots.MarginQuantileText(),
    )
)
```


== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        pairplots.MarginHist(),
        # New:
        pairplots.MarginQuantileText(),
    ))
)
```


:::


![](ex15.png)


We can also include lines in the plot using `MarginQuantileLines`:

::: tabs

== julia

```julia
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),
        PairPlots.MarginHist(),
        PairPlots.MarginQuantileText(),
        # New:
        PairPlots.MarginQuantileLines(),
    )
)
```


== python

```python
pairplots.pairplot(
    (df, (
        pairplots.HexBin(colormap=pairplots.Makie.cgrad(['transparent', 'black'])),
        pairplots.Scatter(filtersigma=2, color='black'),
        pairplots.Contour(color='black'),
        pairplots.MarginHist(),
        # New:
        pairplots.MarginQuantileText(),
    ))
)
```


:::


![](ex15b.png)


## Truth Lines {#Truth-Lines}

You can quickly add lines to mark particular values of each variable on all subplots using `Truth`:

::: tabs

== julia

```julia
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


## Trend Lines {#Trend-Lines}

You can quickly add a linear trend line to each pair of variables by passing a trend-line series:

::: tabs

== julia

```julia
pairplot(
    df => (
        PairPlots.Scatter(),
        PairPlots.MarginHist(),
        PairPlots.TrendLine(color=:red), # default is red
    ),
    fullgrid=true
)
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


## Correlation {#Correlation}

You can add a calculated correlation value between every pair of variables by passing `PairPlots.Correlation()`. You can customize the number of digits and the position of the text.

::: tabs

== julia

```julia
pairplot(
    df => (
        PairPlots.Scatter(),
        PairPlots.MarginHist(),
        PairPlots.TrendLine(color=:red), # default is red
        PairPlots.PearsonCorrelation()
    ),
    fullgrid=true
)
```


== python

```python
pairplots.pairplot(
    (df, (
        pairplots.Scatter(),
        pairplots.MarginHist(),
        pairplots.TrendLine(color='red'), # default is red
        pairplots.PearsonCorrelation()
    )),
    fullgrid=True
)
```


:::


![](ex18.png)


`PairPlots.PearsonCorrelation()` is an alias for `PairPlots.Calculation(StatsBase.cor)`. Feel free to pass any function that accepts two AbstractVectors and calculates a number:

```julia
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

![](rzgzzli.png){width=757px height=753px}

## Customize Axes {#Customize-Axes}

You can customize the axes of the subplots freely in two ways. For these examples, we&#39;ll create a variable that is log-normally distributed.

::: tabs

== julia

```julia
dfln = DataFrame(;α, β, γ=10 .^ γ, δ)
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

```julia
pairplot(dfln, bodyaxis=(;xgridvisible=true, ygridvisible=true))
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

```julia
pairplot(dfln, diagaxis=(;yscale=Makie.pseudolog10, ygridvisible=true))
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

```julia
pairplot(
    dfln => (PairPlots.Scatter(), PairPlots.MarginStepHist()),
    axis=(;
        γ=(;
            scale=log10
        )
    )
)
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


::: tip Note

Do not prefix the attribute with `x` or `y`. PairPlots.jl will add the correct prefix as needed.

:::

::: warning Warning

Log scale variables usually work best with Scatter series. Histogram and contour based series sometimes extend past zero, breaking the scale.

:::

There is also special support for setting the axis limits of each variable. The following applies the correct limits either to the vertical axis or horizontal axis as appropriate. Note that the parameters `low` and/or `high` must be passed as a named tuple.

::: tabs

== julia

```julia
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


## Adding a title {#Adding-a-title}

::: tabs

== julia

```julia
fig = pairplot(df)
Label(fig[0,:], "This is the title!")
fig
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


## Customize bins {#Customize-bins}

There are a few different ways you can customize the bin sizing.

First, you can customize the number of bins by passing the argument `bins=n` to relevant series, eg `Hist(bins=10)`.

Second, you can specify the number of bins by series by passing a dictionary of bin sizes:

```julia
pairplot(df, bins=Dict(
    :α => 5,
    :β => 10,
    :γ => 20,
    :δ => 40,
))
```

![](vicemhw.png){width=755px height=777px}

Third, you can specify the exact bin ranges for all series. Note! If you go this route, you must provide the bin ranges (not counts) for all series, not just some series. You can&#39;t mix and match.

```julia
pairplot(df, bins=Dict(
    :α => -5:0.01:15,
    :β => -10:0.02:15,
    :γ => -5:0.1:5,
    :δ => -10:1:10,
))
```

![](ictdfxm.png){width=757px height=774px}

The bin ranges don&#39;t directly control the axis limits. To control those, use the axis argument:

```julia
pairplot(df, bins=Dict(
        :α => -5:0.01:15,
        :β => -10:0.02:15,
        :γ => -5:0.1:5,
        :δ => -10:1:10,
    ),
    axis = Dict(
        :α => (;lims=(low=0, high=5)),
        :β => (;lims=(low=0, high=5)),
        :γ => (;lims=(low=0, high=5)),
        :δ => (;lims=(low=0, high=5)),
    )
)
```

![](qsxoxtw.png){width=743px height=763px}

Be aware that the `HexBin` layer doesn&#39;t obey specific bin ranges. If you want the body 2D histograms to match, then you should replace `HexBin` with `Hist`:

```julia
pairplot(
    df=>(
        PairPlots.Hist(colormap=Makie.cgrad([:transparent, "#333"])),
        PairPlots.Scatter(filtersigma=2),
        PairPlots.Contour(linewidth=1.5),
        PairPlots.MarginHist(color=Makie.RGBA(0.4,0.4,0.4,0.15)),
        PairPlots.MarginStepHist(color=Makie.RGBA(0.4,0.4,0.4,0.8)),
        PairPlots.MarginDensity(
            color=:black,
            linewidth=1.5f0
        ),
        PairPlots.MarginQuantileText(color=:black,font=:regular),
        PairPlots.MarginQuantileLines(),
    ),
    bins=Dict(
        :α => 0:0.01:5,
        :β => 0:0.1:5,
        :γ => 0:0.25:5,
        :δ => 0:1:5,
    ),
    axis = Dict(
        :α => (;lims=(low=0, high=5)),
        :β => (;lims=(low=0, high=5)),
        :γ => (;lims=(low=0, high=5)),
        :δ => (;lims=(low=0, high=5)),
    )
)
```

![](ciyhxjk.png){width=743px height=763px}

You can either pass the `bins` dict for an entire pair plot, or for particular series by using it as an argument to `Series`.

## Layouts {#Layouts}

The `pairplot` function integrates easily within larger Makie Figures.

::: tip Note

This functionality is not directly exposed to Python, but is available through the `pairplots.Makie` submodule.

:::

Customizing the figure:

```julia
fig = Figure(size=(400,400))
pairplot(fig[1,1], df => (PairPlots.Contourf(),))
fig
```

![](ddcjrdf.png){width=400px height=400px}

::: tip Note

If you only need to pass arguments to `Figure`, for convenience you can use `pairplot(df, figure=(;...))`.

:::

You can plot into one part of a larger figure:

```julia
fig = Figure(size=(800,800))

scatterlines(fig[1,1], randn(40))

pairplot(fig[1,2], df)

lines(fig[2,:], randn(200))


colsize!(fig.layout, 2, 450)
rowsize!(fig.layout, 1, 450)

fig
```

![](szmtnym.png){width=800px height=800px}

Adjust the spacing between axes inside a pair plot:

```julia
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

![](wfxuelw.png){width=600px height=600px}

## Multiple Series {#Multiple-Series}

You can plot multiple series by simply passing more than one table to `pairplot` They don&#39;t have to have all the same column names.

::: tabs

== julia

```julia
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

```julia
c1 = Makie.wong_colors(0.5)[3]
c2 = Makie.wong_colors(0.5)[4]
pairplot(
    PairPlots.Series(table1, label="table 1", color=c1, strokecolor=c1),
    PairPlots.Series(table2, label="table 2", color=c2, strokecolor=c2),
)
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

```julia
pairplot(
    table2 => (PairPlots.HexBin(colormap=:magma), PairPlots.MarginDensity(color=:orange),  PairPlots.MarginQuantileText(color=:black)),
    table1 => (PairPlots.Contour(color=:cyan, strokewidth=5),),
)
```


== python

```python
pairplots.pairplot(
    (table2, (
        pairplots.HexBin(colormap='magma'),
        pairplots.MarginDensity(color='orange'),
        pairplots.MarginQuantileText(color='black')
    )),
    (table1, (
        pairplots.Contour(color='cyan', strokewidth=5),)
    ),
)
```


:::


![](ex27.png)


## Comparing series across the diagonal {#Comparing-series-across-the-diagonal}

If you want to place one series on the left side of the plot and another series on the right side of the plot, you can specify `bottomleft` and `topright` separately for each series:

```julia
table1 = (;
    x = 2randn(10000),
    y = 3randn(10000),
    z = randn(10000),
)

table2 = (;
    x = 2 .+ randn(10000),
    y = 4 .+ randn(10000),
    z = 2 .- randn(10000),
)

c1 = Makie.wong_colors()[1]
layers_series_1 = (
    PairPlots.Scatter(filtersigma=3, color=c1, markersize=2),
    PairPlots.Contourf(strokewidth=1.5,color=(c1,0.15), bandwidth=2, sigmas=[1,3]),
    PairPlots.MarginHist(color=(c1, 0.15)),
    PairPlots.MarginStepHist(color=(c1, 0.8)),
    PairPlots.MarginDensity(
        color=c1,
        linewidth=1.5f0
    ),
)

c2 = Makie.wong_colors()[2]
layers_series_2 = (
    PairPlots.Scatter(filtersigma=3, color=c2, markersize=2),
    PairPlots.Contourf(strokewidth=1.5,color=(c2,0.15), bandwidth=2, sigmas=[1,3]),
    PairPlots.MarginHist(color=(c2,0.15)),
    PairPlots.MarginStepHist(color=(c2,0.8)),
    PairPlots.MarginDensity(
        color=c2,
        linewidth=1.5f0
    ),
)

pairplot(
    PairPlots.Series(table1, bottomleft=true, topright=false) => layers_series_1,
    PairPlots.Series(table2, bottomleft=false, topright=true) => layers_series_2,
)
```

![](xkbbwpd.png){width=587px height=583px}

Another alternative would be to put one on both sides, and the other only on one side:

```julia
pairplot(
    PairPlots.Series(table1, bottomleft=true, topright=false) => layers_series_1,
    PairPlots.Series(table2, bottomleft=true, topright=true) => layers_series_2,
)
```

![](aftbzwv.png){width=587px height=583px}

## Merging two separate pair plots {#Merging-two-separate-pair-plots}

If you want to combine two distinct pair plots, you can do so by plotting into your own figure object, and setting `bottomleft` and `topright` appropriately. 

For example, this might be useful if you want to compare two series with very different variances.

```julia
table1 = (;
    x = 20randn(10000),
    y = 30randn(10000),
    z = 50randn(10000),
    α = 15randn(10000),
)

table2 = (;
    x = 2 .+ randn(10000),
    y = 4 .+ randn(10000),
    z = 2 .- randn(10000),
    α = 5 .- randn(10000),
)


fig = Figure(
    # You will need to adjust this yourself to make all the text etc.
    # the right size
    size=(800,800)
)


c1 = Makie.wong_colors()[1]
layers_series_1 = (
    PairPlots.Scatter(filtersigma=3, color=c1, markersize=2),
    PairPlots.Contourf(strokewidth=1.5,color=(c1,0.15), bandwidth=2, sigmas=[1,3]),
    PairPlots.MarginHist(color=(c1, 0.15)),
    PairPlots.MarginStepHist(color=(c1, 0.8)),
    PairPlots.MarginDensity(
        color=c1,
        linewidth=1.5f0
    ),
)

c2 = Makie.wong_colors()[2]
layers_series_2 = (
    PairPlots.Scatter(filtersigma=3, color=c2, markersize=2),
    PairPlots.Contourf(strokewidth=1.5,color=(c2,0.15), bandwidth=2, sigmas=[1,3]),
    PairPlots.MarginHist(color=(c2,0.15)),
    PairPlots.MarginStepHist(color=(c2,0.8)),
    PairPlots.MarginDensity(
        color=c2,
        linewidth=1.5f0
    ),
)


# You can either:
# (A) plot into any layout range of your figure directly by passing `fig[?,?]` to pairplot() for free layout
# or (B) plot into a shared GridLayout to get nice alignment between the halves:
gs = GridLayout(fig[1,1])

pairplot(
    gs[2:5,1:4],
    table1 => layers_series_1,
    # table2 => layers_series_2,
    bottomleft=true, topright=false
)

pairplot(
    gs[1:4,2:5],
    table2 => layers_series_2,
    bottomleft=false, topright=true
)
fig
```

![](qrngvtd.png){width=800px height=800px}

Finally, here&#39;s one more alternative layout to drive your readers mad:

```julia
fig = Figure(
    # You will need to adjust this yourself to make all the text etc.
    # the right size
    size=(800,800)
)




# Now the key part: call pairplot twice into different parts of the figure:
pairplot(
    fig[1,2],
    table1 => layers_series_1,
    # table2 => layers_series_2,
    bottomleft=true, topright=false
)

pairplot(
    fig[2,1],
    table2 => layers_series_2,
    bottomleft=false, topright=true
)

rowgap!(fig.layout,-70)
colgap!(fig.layout,-70)


fig
```

![](ujsjctv.png){width=800px height=800px}
