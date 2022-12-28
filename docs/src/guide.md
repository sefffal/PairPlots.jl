# Guide


This guide demonstrates the usage of PairPlots and shows several ways you can customize it to your liking.

Set up:
```@example 1
using CairoMakie
using PairPlots
using DataFrames
```
CairoMakie is great for making high quality static figures. Try GLMakie or WGLMakie for interactive plots!

We will use DataFrames here to wrap our tables and provide pleasant table listings. You can use any Tables.jl compatible source, including simple named tuples of vectors for each column.

## Single Series

Let's create a basic table of data to vizualize.

```@example 1
N = 100_000
α = [2randn(N÷2) .+ 6; randn(N÷2)]
β = [3randn(N÷2); 2randn(N÷2)]
γ = randn(N)
δ = β .+ 0.6randn(N)

df = DataFrame(;α, β, γ, δ)
df[1:8,:] # hide
```


We can plot this data directly using `pairplot`, and add customizations iteratively.
```@example 1
pairplot(df)
```

Override the axis labels:
```@example 1
pairplot(
    df,
    labels = Dict(
        # basic string
        :α => "parameter 1",
        # Makie rich text
        :β => rich("parameter 2", font=:bold, color=:blue),
        # LaTeX String
        :γ => L"\frac{a}{b}",
    )
)
```

Let's move onto more complex examples. The full syntax of the `pairplot` function is:
```julia
pairplot(
    PairPlots.Series(source) => (::PairPlots.VizType...),
)
```
That is, it accepts a list of pairs of `PairPlots.Series` `=>` a tuple of "vizualiation layers". As we'll see later on, you can pass keyword arguments with a series, or a specific vizualization layer to customize their behaviour and appearance.
If you don't need to adjust any parameters for a whole series, you can just pass in a data source and PairPlots will wrap it for you:
```julia
pairplot(
    source => (::PairPlots.VizType...),
)
```

Let's see how this works by iteratively building up the default vizualiation.
First, create a basic histogram plot:
```@example 1
pairplot(
    df => (PairPlots.Hist(),) # note the comma
)
```

!!! note
    A tuple or list of vizualization types is required, even if you just want one. Make sure to include the comma in these examples.

Or, a histogram with hexagonal binning:
```@example 1
pairplot(
    df => (PairPlots.HexBin(),)
)
```

Scatter plots:
```@example 1
pairplot(
    df => (PairPlots.Scatter(),)
)
```

Filled contour plots:
```@example 1
pairplot(
    df => (PairPlots.Contourf(),)
)
```

Outlined contour plots:
```@example 1
pairplot(
    df => (PairPlots.Contour(),)
)
```

Now let's combine a few plot types. 
Scatter and contours:
```@example 1
pairplot(
    df => (PairPlots.Scatter(), PairPlots.Contour())
)
```

Scatter and contours, but hiding points above $2\sigma$:
```@example 1
pairplot(
    df => (PairPlots.Scatter(filtersigma=2), PairPlots.Contour())
)
```

Placing a HexBin series underneath:
```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black)
    )
)
```

### Margin plots
We can add additional vizualization layers to the diagonals of the plots using the same syntax.
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
```


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
```

```@example 1
pairplot(
    df => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black])),
        PairPlots.Scatter(filtersigma=2, color=:black),
        PairPlots.Contour(color=:black),

        # New:
        PairPlots.MarginDensity(),
        PairPlots.MarginConfidenceLimits(),
    )
)
```

## Adding a title

```@example 1
fig = pairplot(df)
Label(fig[0,:], "This is the title!")
fig
```

## Layouts
The `pairplot` function integrates easily within larger Makie Figures.

Customizing the figure:
```@example 1
fig = Figure(resolution=(400,400))
pairplot(fig[1,1], df => (PairPlots.Contourf(),))
fig
```

!!! note
    If you only need to pass arguments to `Figure`, for convenience you can use `pairplot(df, figure=(;...))`.


You can plot into one part of a larger figure:

```@example 1
fig = Figure(resolution=(800,800))

scatterlines(fig[1,1], randn(40))

pairplot(fig[1,2], df)

lines(fig[2,:], randn(200))


colsize!(fig.layout, 2, 450)
rowsize!(fig.layout, 1, 450)

fig

```

Adjust the spacing between axes inside a pair plot:

```@example 1
fig = Figure(resolution=(600,600))

# pairplots must go into a GridLayout. If you pass a GridPosition instead,
# PairPlots will create one for you.
# We can then adjust the spacing within that GridLayout.

gs = GridLayout(fig[1,1])
pairplot(gs, df)

rowgap!(gs, 0)
colgap!(gs, 0)

fig
```



## Multiple Series
