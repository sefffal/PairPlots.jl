# Getting Started

If you don't need any customization, the easiest way to get started is to call `pairplot` with one or more tables or matrices.


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
```
The axis labels are taken from the column names by default, but you can customize them (see [Guide](@ref)).



If you're in a hurry, you can just pass a Matrix directly (or any subtype of AbstractMatrix).
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
```


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

pairplot(table1, table2)
```
