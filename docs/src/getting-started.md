# Getting Started


You can install PairPlots from the Julia registry or from the python package index via `pip`:

::: tabs

== julia
```julia
using PairPlots
```
Hit enter at the prompt to accept the installation.

== python

```bash
pip install -U pairplots
```
:::



If you don't need any customization, the easiest way to get started is to call `pairplot` with one or more tables or matrices.


::: tabs

== julia
```@example 1
using CairoMakie
using PairPlots

# The simplest table format is just a named tuple of vectors.
# You can also pass a DataFrame, or any other Tables.jl compatible object.
table = (;
    x = randn(10000),
    y = randn(10000),
)

pairplot(table)
save("ex1.png", ans) # hide
nothing # hide
```

== python

```python
import numpy as np
import pandas as pd
import pairplots

table = pd.DataFrame(
    np.random.randn(10000,2),
    columns=['x', 'y']
)
pairplots.pairplot(table)
```
:::
![](ex1.png)


The axis labels are taken from the column names by default, but you can customize them (see [Guide](@ref)).


If you're in a hurry, you can just pass a matrix/2D-array directly.

::: tabs

== julia
```@example 1
using CairoMakie
using PairPlots
# Columns are treated as variables, and rows as samples.
mat = randn(10000,6)
pairplot(mat)
save("ex2.png", ans) # hide
nothing # hide
```
![](ex2.png)


== python

```python
import numpy as np
import pairplots
# Columns are treated as variables, and rows as samples.
mat = np.random.randn(10000,6)
pairplots.pairplot(mat)
```
![](ex2.png)


Just like corner.py, you can also pass a list of labels for each column:
```python
pairplots.pairplot(mat, labels=["a", "b", "c", "d", "e", "f"])
```
```@example 1
dfpy = ( # hide
    a=randn(10000), # hide
    b=randn(10000), # hide
    c=randn(10000), # hide
    d=randn(10000), # hide
    e=randn(10000), # hide
    f=randn(10000), # hide
) # hide
pairplot(dfpy) # hide
```


:::





Multiple tables are also supported. They don't have to have the same column names.
```@example 1
using CairoMakie
using PairPlots

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

fig = pairplot(table1, table2)
```

You can save your pairplot like so:

::: tabs

== julia
```julia
save("myfigure.png", fig)
```

== python

```python
pairplots.save("myfigure.png", fig)
```
:::

Other formats like `.svg` and `.pdf` are also supported.

!!! tip "Resolution"
    You can increase the resolution of the saved PNG image by passing the `px_per_unit` keyword argument to `save`, as in `save("plot.png", fig, px_per_unit=3)`. The higher the number, the higher the resolution (and larger the file).


## Interactivity
You can view an interactive figure powered by GLMakie:

::: tabs

== julia
```julia
using GLMakie; GLMakie.activate!()
pairplot(table)
```

== python

```python
pairplots.pairplot_interactive(table)
```
:::