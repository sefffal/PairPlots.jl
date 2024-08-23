module PairPlots

export pairplot

using Makie: Makie
using Tables
using TableOperations
using Printf
using KernelDensity: KernelDensity
using Contour: Contour as ContourLib
using OrderedCollections: OrderedDict
using StatsBase: fit, quantile, Histogram, cor
using Distributions: pdf
using StaticArrays
using PolygonOps
using LinearAlgebra: LinearAlgebra
using LinearAlgebra: normalize
using Missings
using NamedTupleTools

"""
    AbstractSeries

Represents some kind of series in PairPlots.
"""
abstract type AbstractSeries end

"""
    Truth(truths; labels=nothing, kwargs=...)

Mark a set of "true" values given by `truths` which should
be either a named tuple, Dict, etc that can be indexed by the
column name and returns a value or values.
"""
struct Truth{T,K} <: AbstractSeries where {T,K}
    label::Union{Nothing,String,Makie.RichText,Makie.LaTeXString}
    table::T
    bottomleft::Bool
    topright::Bool
    kwargs::K
end
function Truth(truths;fullgrid=false,bottomleft=true,topright=fullgrid,label=nothing, kwargs...)
    if !(keytype(truths) isa Symbol)
        truths = NamedTuple([
            Symbol(k) => v
            for (k,v) in pairs(truths)
        ])
    end
    return Truth(label, truths,bottomleft, topright, kwargs)
end
# Can be removed once we only support Julia 1.10+
Truth(truths::NamedTuple;label=nothing, fullgrid=false,bottomleft=true,topright=fullgrid,kwargs...) = Truth(label, truths, bottomleft, topright, kwargs)



struct Series{T,K} <: AbstractSeries where {T,K}
    label::Union{Nothing,String,Makie.RichText,Makie.LaTeXString}
    table::T
    bottomleft::Bool
    topright::Bool
    bins::Dict{Symbol,Any}
    kwargs::K
end
"""
    Series(data; label=nothing, kwargs=...)

A data series in PairPlots. Wraps a Tables.jl compatible table.
You can optionally pass a label for this series to use in the plot legend.
Keyword arguments are forwarded to every plot call for this series.

Examples:
```julia
ser = Series(table; label="series 1", color=:red)
```
"""
function Series(data; label=nothing,fullgrid=false,bottomleft=true,topright=fullgrid,bins=Dict{Symbol,Any}(), kwargs...)
    if !Tables.istable(data)
        error("PairPlots expects a matrix or Tables.jl compatible table for each series.")
    end
    bins = convert(Dict{Symbol,Any}, bins)
    Series(label, data,bottomleft,topright,bins,kwargs)
end
"""
    Series(matrix::AbstractMatrix; label=nothing, kwargs...)

Convenience constructor to build a Series from an abstract matrix.
The columns are named accordingly to the axes of the Matrix (usually :1 though N).
"""
function Series(data::AbstractMatrix; label=nothing,fullgrid=false,bottomleft=true,topright=fullgrid,bins=Dict{Symbol,Any}(), kwargs...)
    column_labels = [Symbol(i) for i in axes(data,1)]
    table = NamedTuple([
        collabel => col
        for (collabel, col) in zip(column_labels, eachcol(data))
    ])
    bins = convert(Dict{Symbol,Any}, bins)
    Series(label, table, bottomleft, topright, bins, kwargs)
end

"""
A type of PairPlots visualization. `VizType` is the supertype for all PairPlots visualization types.
"""
abstract type VizType end

"""
    VizTypeBody <: VizType

A type of PairPlots visualization that compares two variables.
"""
abstract type VizTypeBody <: VizType end

## Note: these are deliberately not concretely typed. They just store keyword arguments
## that will vary as the user is modifying plots. No point in specializing on them.

"""
    HexBin(;kwargs...)

Plot two variables against eachother using a Makie Hex Bin series.
`kwargs` are forwarded to the plot function and can be used to control
the number of bins and the appearance.
"""
struct HexBin <: VizTypeBody
    kwargs
    HexBin(;kwargs...) = new(kwargs)
end

"""
    Hist(;kwargs...)
    Hist(histprep_function; kwargs...)

Plot two variables against eachother using a 2D histogram heatmap.
`kwargs` are forwarded to the plot function and can be used to control
the number of bins and the appearance.

!!! note
    You can optionally pass a function to override how the histogram is calculated.
    It should have the signature: `prepare_hist(xs, ys, nbins)` and return
    a vector of horizontal bin centers, vertical bin centers, and a matrix of weights.

    !!! tip
        Your `prepare_hist` function it does not have to obey `nbins`
"""
struct Hist{T} <: VizTypeBody where T
    prepare_hist::T
    kwargs
    Hist(prepare_hist=prepare_hist;kwargs...) = new{typeof(prepare_hist)}(prepare_hist, kwargs)
end


"""
    Contour(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...)

Plot two variables against eachother using a contour plot. The contours cover the area under a Gaussian
given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can
be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically
by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth`
when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother
contours.

!!! note
    Contours are calculated using Contour.jl and plotted as a Makie line series.

See also: Contourf
"""
struct Contour <: VizTypeBody
    sigmas
    bandwidth
    kwargs
    Contour(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...) = new(sigmas, bandwidth, kwargs)
end

"""
    Contourf(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...)

Plot two variables against eachother using a filled contour plot. The contours cover the area under a Gaussian
given by `sigmas`, which must be `<: AbstractVector`. `kwargs` are forwarded to the plot function and can
be used to control the appearance.

KernelDensity.jl is used to produce smoother contours. The bandwidth of the KDE is chosen automatically
by that package, but you can scale the bandwidth used up or down by a constant factor by passing `bandwidth`
when creating the series. For example, `bandwidth=2.0` will double the KDE bandwidth and result in smoother
contours.

KernelDensity.jl is used to produce smoother contours.

See also: Contour
"""
struct Contourf <: VizTypeBody
    sigmas
    bandwidth
    kwargs
    Contourf(;sigmas=0.5:0.5:2, bandwidth=1.0, kwargs...) = new(sigmas, bandwidth, kwargs)
end

"""
    Scatter(;kwargs...)

Plot two variables against eachother using a scatter plot.`kwargs` are forwarded to the plot function and can
be used to control the appearance.
"""
struct Scatter <: VizTypeBody
    kwargs
    filtersigma
    Scatter(;filtersigma=nothing, kwargs...) = new(kwargs, filtersigma)
end

"""
    TrendLine(;kwargs...)

Fit and plot a trend-line between two variables. Currently only a linear trend-line is supported.
"""
struct TrendLine <: VizTypeBody
    kwargs
    TrendLine(; kwargs...) = new(merge((;color=:red), kwargs))
end


## Diagonals
"""
    VizTypeDiag <: VizType

A type of PairPlots visualization that only shows one variable. Used
for the plots along the diagonal.
"""
abstract type VizTypeDiag <: VizType end


function margin_confidence_default_formatter(low,mid,high)
    largest_error = max(abs(high), abs(low))
    # Fallback for series with no variance
    if largest_error == 0
        if mid == 0
            digits_after_dot = 0
        else
            digits_after_dot = max(0, 1 - round(Int, log10(abs(mid))))
        end
        @static if VERSION >= v"1.10"
            title = @sprintf(
                "%.*f",
                digits_after_dot, mid,
            )
        else
            title = @eval @sprintf(
                $("\$%.$(digits_after_dot)f\$"),
                $mid,
            )
        end
        return title
    end

    digits_after_dot = max(0, 1 - round(Int, log10(largest_error)))
    use_scientific = digits_after_dot > 4

    if use_scientific
        if round(low, digits=digits_after_dot) == round(high, digits=digits_after_dot)
            title = @sprintf(
                "\$(%.1f \\pm %.1f)\\times 10^{-%d}\$",
                mid*10^(digits_after_dot-1),
                high*10^(digits_after_dot-1),
                (digits_after_dot-1)
            )
        else
            title = @sprintf(
                "\$(%.1f^{+%.1f}_{-%.1f})\\times 10^{-%d}\$",
                mid*10^(digits_after_dot-1),
                high*10^(digits_after_dot-1),
                low*10^(digits_after_dot-1),
                (digits_after_dot-1)
            )
        end
    else
        # '*' format specifier only supported in Julia 1.10+
        @static if VERSION >= v"1.10"
            if round(low, digits=digits_after_dot) == round(high, digits=digits_after_dot)
                title = @sprintf(
                    "\$%.*f \\pm %.*f\$",
                    digits_after_dot, mid,
                    digits_after_dot, high,
                )
            else
                title = @sprintf(
                    "\$%.*f^{+%.*f}_{-%.*f}\$",
                    digits_after_dot, mid,
                    digits_after_dot, high,
                    digits_after_dot, low
                )
            end
        else
            if round(low, digits=digits_after_dot) == round(high, digits=digits_after_dot)
                title = @eval @sprintf(
                    $("\$%.$(digits_after_dot)f \\pm %.$(digits_after_dot)f\$"),
                    $mid,
                    $high,
                )
            else
                title = @eval @sprintf(
                    $("\$%.$(digits_after_dot)f^{+%.$(digits_after_dot)f}_{-%.$(digits_after_dot)f}\$"),
                    $mid,
                    $high,
                    $low
                )
            end
        end
    end

    return title
end

function _apply_user_format_string(format)
    return function(low,mid,high)
        title = @eval @sprintf($format, $mid, $high, $low)
        return title
    end
end

"""
    MarginConfidenceLimits(format_string::AbstractString; kwargs...)
    MarginConfidenceLimits(formatter::Base.Callable=margin_confidence_default_formatter; kwargs...)

"""
struct MarginConfidenceLimits <: VizTypeDiag
    formatter::Base.Callable
    quantiles::NTuple{3,Number}
    kwargs
    function MarginConfidenceLimits(format::AbstractString, quantiles=(0.16, 0.5, 0.84); kwargs...)
        return new(_apply_user_format_string(format),  quantiles, kwargs)
    end
    function MarginConfidenceLimits(formatter::Base.Callable=margin_confidence_default_formatter, quantiles=(0.16, 0.5, 0.84); kwargs...)
        return new(formatter, quantiles, kwargs)
    end
end

"""
    MarginHist(;kwargs...)
    MarginHist(histprep_function; kwargs...)

Plot a marginal filled histogram of a single variable along the diagonal of the grid.
`kwargs` are forwarded to the plot function and can be used to control
the number of bins and the appearance.

!!! tip
    You can optionally pass a function to override how the histogram is calculated.
    It should have the signature: `prepare_hist(xs, nbins)` and return
    a vector of bin centers and a vector of weights.

    !!! note
        Your `prepare_hist` function it does not have to obey `nbins`
"""
struct MarginHist{T} <: VizTypeDiag where T
    prepare_hist::T
    kwargs
    MarginHist(prepare_hist=prepare_hist;kwargs...) = new{typeof(prepare_hist)}(prepare_hist, kwargs)
end

"""
    MarginStepHist(;kwargs...)
    MarginStepHist(histprep_function; kwargs...)

Plot a marginal histogram without filled columns of a single variable along the diagonal of the grid.
`kwargs` are forwarded to the plot function and can be used to control
the number of bins and the appearance.

!!! tip
    You can optionally pass a function to override how the histogram is calculated.
    It should have the signature: `prepare_hist(xs, nbins)` and return
    a vector of bin centers and a vector of weights.

    !!! note
        Your `prepare_hist` function it does not have to obey `nbins`
"""
struct MarginStepHist{T} <: VizTypeDiag where T
    prepare_hist::T
    kwargs
    MarginStepHist(prepare_hist=prepare_hist;kwargs...) = new{typeof(prepare_hist)}(prepare_hist, kwargs)
end

"""
    MarginDensity(;kwargs...)

Plot the smoothed marginal density of a variable along the diagonal of the grid, using Makie's `density`
function. `kwargs` are forwarded to the plot function and can be used to control
the appearance.
"""
struct MarginDensity <: VizTypeDiag
    bandwidth::Float64
    kwargs
    MarginDensity(;bandwidth=1.0,kwargs...) = new(bandwidth,kwargs)
end

"""
    Calculation(function; digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)

Apply a function to a pair of variables and add the result as a text label in the appropriate
body subplot. Control the position of the label by passing a different value for `position`.
Change the number of digits to round the result by passing `digits=N`. The first and only
positional argument is the function to use to calculate the correlation.
"""
struct Calculation{F} <: PairPlots.VizTypeBody
    f::F
    label::Symbol
    position::Makie.Point2f
    digits::Int
    kwargs::Any
end
function Calculation(f::Base.Callable; position=Makie.Point2f(0.01, 1.0), digits=3, kwargs...)
    return Calculation(f, nameof(f), position, digits, kwargs)
end

"""
    Correlation(;digits=3, position=Makie.Point2f(0.01, 1.0), kwargs...)

Calculate the correlation between two variables and add it as a text label to the plot.
This is an alias for `Calculation(StatsBase.cor)`.
You can adjust the number of digits, the location of the text, etc. See `Calculation`
for more details.
"""
function Correlation(;kwargs...)
    return Calculation(cor; kwargs...)
end

struct MarginLines <: VizTypeDiag
    kwargs
    MarginLines(;kwargs...) = new(kwargs)
end

struct BodyLines <: VizTypeBody
    kwargs
    BodyLines(;kwargs...) = new(kwargs)
end


GridPosTypes = Union{Makie.Figure, Makie.GridPosition, Makie.GridSubposition}

"""
    pairplot(inputs...; figure=(;), kwargs...)

Convenience method to generate a new Makie figure with resolution (800,800)
and then call `pairplot` as usual. Returns the figure.

Example:
```julia
fig = pairplot(table)
```
"""
function pairplot(
    @nospecialize input...;
    figure=(;),
    bodyaxis=(;),
    diagaxis=(;),
    kwargs...,
)

    # If we make the figure for the user, we can size it nicely
    # for them.
    # Pass in fixed sizes for each plot and then resize the figure
    # afterwards.
    fig = Makie.Figure(;figure...)
                # Default size

    ax_defaults = (;
        width=150,
        height=150,
    )
    pairplot(
        fig.layout,
        input...;
        bodyaxis=(;ax_defaults...,bodyaxis...),
        diagaxis=(;ax_defaults...,diagaxis...),
        kwargs...
    )
    Makie.resize_to_layout!(fig)
    return fig
end


"""
    pairplot(gridpos::Makie.GridPosition, inputs...; kwargs...)

Create a pair plot at a given grid position of a Makie figure.

Example
```julia
fig = Figure()
pairplot(fig[2,3], table)
fig
```
"""
function pairplot(
    gridpos::Makie.GridPosition,
    @nospecialize datapairs::Any...;
    kwargs...,
)
    grid = Makie.GridLayout(gridpos)
    pairplot(grid, datapairs...; kwargs...)
    return grid
end

"""
    pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)

Convenience function to create a reasonable pair plot given
one or more inputs that aren't full specified.
Wraps input tables in PairPlots.Series() with a distinct color specified
for each series.

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
"""
function pairplot(
    grid::Makie.GridLayout,
    @nospecialize datapairs::Any...;
    fullgrid=false,bottomleft=true,topright=fullgrid,
    bins=Dict{Symbol,Any}(),
    kwargs...,
)
    # Default to grayscale for a single series.
    # Otherwise fall back to cycling the colours ourselves.
    # The Makie color cycle functionality isn't quite flexible enough (but almost!).

    bins = convert(Dict{Symbol,Any}, bins)

    series_i = 0
    function SeriesDefaults(dat)
        series_i += 1
        wc = Makie.wong_colors(0.5)
        color = wc[mod1(series_i, length(wc))]
        return Series(dat; color, bottomleft, topright, bins, strokecolor=color)
    end

    countser((data,vizlayers)::Pair) = countser(data)
    countser(series::Series) = 1
    countser(truths::Truth) = 0
    countser(data::Any) = 1
    len_datapairs_not_truth = sum(countser, datapairs)

    if len_datapairs_not_truth == 1
        defaults1((data,vizlayers)::Pair) = Series(data;  bottomleft, topright, bins, color=single_series_color) => vizlayers
        defaults1(series::Series) = series => single_series_default_viz
        defaults1(truths::Truth) = truths => truths_default_viz
        defaults1(data::Any) = Series(data; bottomleft, topright, bins, color=single_series_color) => single_series_default_viz
        return pairplot(grid, map(defaults1, datapairs)...; kwargs...)
    elseif len_datapairs_not_truth <= 5
        defaults_upto5((data,vizlayers)::Pair) = SeriesDefaults(data) => vizlayers
        defaults_upto5(series::Series) = series => multi_series_default_viz
        defaults_upto5(truths::Truth) = truths => truths_default_viz
        defaults_upto5(data::Any) = SeriesDefaults(data) => multi_series_default_viz
        return pairplot(grid, map(defaults_upto5, datapairs)...; kwargs...)
    else # More than 5 series
        defaults_morethan5((data,vizlayers)::Pair) = SeriesDefaults(data) => vizlayers
        defaults_morethan5(series::Series) = series => many_series_default_viz
        defaults_morethan5(truths::Truth) = truths => truths_default_viz
        defaults_morethan5(data::Any) = SeriesDefaults(data) => many_series_default_viz
        return pairplot(grid, map(defaults_morethan5, datapairs)...; kwargs...)
    end

end

# Create a pairplot by plotting into a grid position of a figure.

"""
    pairplot(gridpos::Makie.GridLayout, inputs...; kwargs...)

Main PairPlots function. Create a pair plot by plotting into a grid
layout within a Makie figure.

Inputs should be one or more `Pair` of PairPlots.AbstractSeries => tuple of VizType.

Additional arguments:
* labels: customize the axes labels with a Dict of column name (symbol) to string, Makie rich text, or LaTeX string.
* diagaxis: customize the Makie.Axis of plots along the diagonal with a named tuple of keyword arguments.
* bodyaxis: customize the Makie.Axis of plots under the diagonal with a named tuple of keyword arguments.
* axis: customize the axes by parameter using a Dict of column name (symbol) to named tuple of axis settings. `x` and `y` are automatically prepended based on the parameter and subplot.  For global properties, see `diagaxis` and `bodyaxis`.
* legend:  additional keyword arguments to the Legend constructor, used if one or more series are labelled. You can of course also create your own Legend and inset it into the Figure for complete control.
* fullgrid: true or false (default). Show duplicate plots above the diagonal to make a full grid.

## Examples

Basic usage:
```julia
table = (;a=randn(1000), b=randn(1000), c=randn(1000))
pairplot(table)
```

Customize labels:
```julia
pairplot(table, labels=Dict(:a=>L"\\sum{a^2}"))
```


Use a pseudo log scale for one variable:
```julia
pairplot(table, axis=(; a=(;scale=Makie.pseudolog10) ))
```
"""
function pairplot(
    grid::Makie.GridLayout,
    @nospecialize pairs::Pair{<:AbstractSeries}...;
    labels::AbstractDict{Symbol} = Dict{Symbol,Any}(),
    axis::Union{AbstractDict{Symbol},NamedTuple} = Dict{Symbol,Any}(),
    diagaxis=(;),
    bodyaxis=(;),
    legend=(;),
    flipaxislabels=false
)

    display_bottomleft_axes = any(k.bottomleft for (k,v) in pairs)
    display_topright_axes = any(k.topright for (k,v) in pairs)
    if display_topright_axes && !display_bottomleft_axes
        flipaxislabels = true
    end

    # Filter out rows with any missing values from each series
    # Keep track of how many we removed from each so that we can report
    # it to the user.
    missing_counts = Int[]
    pairs_no_missing = map(pairs) do (series, vizlayers)
        if series isa Truth
            push!(missing_counts,  0)
            return series => vizlayers
        end
        tbl = series.table
        tbl_not_missing = Tables.columntable(TableOperations.dropmissing(tbl))
        len_before = nrows(tbl)
        len_after = nrows(tbl_not_missing)
        push!(missing_counts, len_before - len_after)
        return Series(series.label, tbl_not_missing, series.bottomleft, series.topright, series.bins, series.kwargs) => vizlayers
    end

    # We support multiple series that may have disjoint columns
    # Get the ordered union of all table columns.
    columns = unique(Iterators.flatten(Iterators.map(columnnames∘first, pairs_no_missing)))

    # Merge label maps determined from each series.
    # Error if they are different! That would imply the user passed multiple tables
    # with the same named columns but having eg. conflicting units.
    label_map = Dict{Symbol,Union{String,Makie.RichText}}()
    for (series, viz) in pairs_no_missing
        for key in columnnames(series)
            label = default_label_string(key, getcolumn(series,  key))
            if haskey(label_map, key) && label_map[key] != label
                @warn "Conflicting labels found for column $key. Do the units match?" label1=label_map[key] label2=label
            else
                label_map[key] = label
            end
        end
    end
    label_map = merge(label_map, Dict(labels)) # user's passed labels Dict overrides all

    # Rather than computing limits in this version, let's try to rely on
    # Makie doing a good job of linking axes.

    N = length(columns)

    # Keep lists of axes by row number and by column number.
    # We'll use these afterwards to link axes together.
    axes_by_row = Dict{Int,Vector{Makie.Axis}}()
    axes_by_col = Dict{Int,Vector{Makie.Axis}}()
    sizehint!(axes_by_col, N)
    sizehint!(axes_by_row, N)

    # Check if there are any diagonal visualization layers
    anydiag_viz = mapreduce((|), pairs_no_missing, init=false) do (series, vizlayers)
        any(v->isa(v, VizTypeDiag), vizlayers)
    end

    orphaned_diag_axis = nothing
    # Build grid of nxn plots
    for row_ind in 1:N, col_ind in 1:N

        if (!display_topright_axes && row_ind < col_ind) || (row_ind==col_ind && !anydiag_viz)
            continue
        end
        if (!display_bottomleft_axes && row_ind > col_ind) || (row_ind==col_ind && !anydiag_viz)
            continue
        end

        colname_row = columns[row_ind]
        colname_col = columns[col_ind]


        xkw = get(axis, colname_col, (;))
        xkw = (
            Symbol('x',key) => value
            for (key,value) in zip(keys(xkw), values(xkw)) if Symbol(key) != :lims
        )
        xlims = get(get(axis, colname_col, (;)), :lims, (;))
        if row_ind == col_ind
            kw = diagaxis
            # Don't apply axis paramters to vertical axis of diagonal plots (e.g. histogram scale)
            ykw = (;)
            ylims = (;)
        else
            kw = bodyaxis
            ykw = get(axis, colname_row, (;))
            ykw = (
                Symbol('y',key) => value
                for (key,value) in zip(keys(ykw), values(ykw)) if key != :lims
            )
            ylims = get(get(axis, colname_row, (;)), :lims, (;))
        end

        # Hide first row if no diagonal viz layers
        row_ind_fig = row_ind
        if !anydiag_viz
            row_ind_fig = row_ind - 1
        end

        # Hide labels etc. as needed for a compact view
        if flipaxislabels
            if 1 < row_ind
                kw = (;xlabelvisible=false, xticklabelsvisible=false, xticksvisible=false, kw...)
            end
            if col_ind < N
                kw = (;ylabelvisible=false, yticklabelsvisible=false, yticksvisible=false, kw...)
            end

            # Rotate tick labels to avoid overlap in some cases.
            # Ideally we would detect when this is necessary but I found the code was too complicated
            if row_ind == 1
                kw = (;
                    xticklabelrotation = (pi/4),
                    xaxisposition=:top,
                    yaxisposition=:right,
                    kw...,
                )
            end
            if col_ind == N
                kw = (;
                    yticklabelrotation = (pi/4),
                    xaxisposition=:top,
                    yaxisposition=:right,
                    kw...,
                )
            end
        else
            if row_ind < N
                kw = (;xlabelvisible=false, xticklabelsvisible=false, xticksvisible=false, kw...)
            end
            if col_ind > 1 || row_ind == 1
                kw = (;ylabelvisible=false, yticklabelsvisible=false, yticksvisible=false, kw...)
            end

            # Rotate tick labels to avoid overlap in some cases.
            # Ideally we would detect when this is necessary but I found the code was too complicated
            if row_ind == N
                kw = (;
                    xticklabelrotation = (pi/4),
                    kw...,
                )
            end
            if col_ind == 1
                kw = (;
                    yticklabelrotation = (pi/4),
                    kw...,
                )
            end
        end

        ax = Makie.Axis(
            grid[row_ind_fig, col_ind];
            ylabel=label_map[colname_row],
            xlabel=label_map[colname_col],
            xgridvisible=false,
            ygridvisible=false,
            # Ensure any axis title that gets added doesn't break the tight layout
            alignmode = row_ind == 1 ? Makie.Inside() : Makie.Mixed(;left=nothing, right=nothing, bottom=nothing, top=Makie.Protrusion(display_bottomleft_axes ? 0.0 : 0.1)),
            xautolimitmargin=(0f0,0f0),
            yautolimitmargin= row_ind == col_ind ? (0f0, 0.05f0) : (0f0,0f0),
            # User options
            xkw...,
            ykw...,
            kw...,
        )

        if xlims != (;)
            Makie.xlims!(ax; xlims...)
        end
        if ylims != (;)
            Makie.ylims!(ax; ylims...)
        end

        axes_by_col[col_ind]= push!(get(axes_by_col, col_ind, Makie.Axis[]), ax)
        if row_ind != col_ind || (!display_bottomleft_axes && row_ind == N)
            axes_by_row[row_ind]= push!(get(axes_by_row, row_ind, Makie.Axis[]), ax)
        end
        if (display_bottomleft_axes && row_ind == N) || (!display_bottomleft_axes && col_ind ==1 && row_ind == 1)
            orphaned_diag_axis = ax
        end

        # For each slot, loop through all series and fill it in accordingly.
        # We have two slot types: bodyplot, like a 3D histogram, and diagplot, along the diagonal
        for (series, vizlayers) in pairs_no_missing
            if (!series.topright && row_ind < col_ind)
                continue
            end
            if (!series.bottomleft && row_ind > col_ind)
                continue
            end
            for vizlayer in vizlayers
                if row_ind == col_ind && vizlayer isa VizTypeDiag
                    diagplot(ax, vizlayer, series, colname_row)
                elseif row_ind != col_ind && vizlayer isa VizTypeBody
                    bodyplot(ax, vizlayer, series, colname_row, colname_col)
                else
                    # skip
                end
            end
        end
    end

    # Link all axes
    for axes in values(axes_by_row)
        Makie.linkyaxes!(axes...)
    end
    for axes in values(axes_by_col)
        Makie.linkxaxes!(axes...)
    end
    # Wishlist: link x axis of bottom right diagonal plot with y axis of bottom row.

    # Ensure labels are spaced nicely
    if display_bottomleft_axes && N > 1
        last_row = axes_by_row[N]
        if !isnothing(orphaned_diag_axis)
            push!(axes_by_row[N], orphaned_diag_axis)
        end
        yspace = maximum(Makie.tight_yticklabel_spacing!, last_row)
        xspace = maximum(Makie.tight_xticklabel_spacing!, axes_by_col[1])
        for ax in last_row
            ax.xticklabelspace = xspace + 10
        end
        for ax in axes_by_col[1]
            ax.yticklabelspace = yspace
        end
    end
    if !display_bottomleft_axes && N > 1
        first_row = axes_by_row[1]
        if !isnothing(orphaned_diag_axis)
            push!(first_row, orphaned_diag_axis)
        end
        xspace = maximum(Makie.tight_xticklabel_spacing!, first_row)
        yspace = maximum(Makie.tight_yticklabel_spacing!, axes_by_col[N])
        for ax in first_row
            ax.xticklabelspace = xspace + 10
        end
        for ax in axes_by_col[1]
            ax.yticklabelspace = yspace
        end

    end

    # Add legend if needed (any series has a non-nothing label)
    if any(((ser,_),)->!isnothing(ser.label), pairs_no_missing)

        legend_strings = map(((ser,_),)->isnothing(ser.label) ? "" : ser.label, pairs_no_missing)
        legend_entries = map(pairs_no_missing) do (ser, _)
            kwargs = ser.kwargs
            if haskey(kwargs, :color) && kwargs[:color] isa Tuple
                # Don't pass transparency into the legend
                color = kwargs[:color][1]
                kwargs = (;kwargs...,color)
            end
            Makie.LineElement(;kwargs...,strokwidth=2)
        end
        M = N
        if !anydiag_viz
            M -= 1
        end
        if display_bottomleft_axes && !display_topright_axes
            pos = grid[M == 1 ? 1 : end-1, M <= 2 ? 2 : M ]
        elseif !display_bottomleft_axes && display_topright_axes
            # TODO
            pos = grid[M == 1 ? 1 : end, N <= 2 ? 2 : M-1 ]
        else
            # Extend the grid out sideways to accomodate
            pos = grid[begin,end+1] 
        end
        Makie.Legend(
            pos,
            collect(legend_entries),
            collect(legend_strings);
            tellwidth=false,
            tellheight=false,
            valign = display_bottomleft_axes ? :bottom : :top,
            halign = display_bottomleft_axes ? :left : :right,
            legend...
        )
    end

    # Add a bottom annotation listing the count of rows skipped for missing data by series
    # We want each annotation on a separate line. But we can't use Base.join() for
    # Makie.rich text... Need to do it ourselves.
    for (i,(missing_count, (series,viz))) in enumerate(zip(missing_counts, pairs_no_missing))
        if missing_count == 0
            continue
        end
        # If there is only one series, we don't have mention it by name in the text annotation.
        if length(pairs_no_missing) == 1
            missing_text = Makie.rich("$missing_count rows with missing values are hidden.")
        else
            label = series.label
            if isnothing(label)
                label = "$i"
            end
            kwargs = (;)
            if haskey(series.kwargs, :color)
                color = series.kwargs[:color]
                if color isa Tuple
                    # Don't pass transparency into the label
                    color = color[1]
                end
                kwargs = (;color)
            end
            missing_text = Makie.rich("$missing_count rows with missing values are hidden from series $label."; kwargs...)
        end
        # Add an annotation to the bottom listing the counts of missing values that
        # were skipped.
        Makie.Label(
            grid[end+1,:],
            missing_text,
            halign=:left
        )
        if i > 1
            Makie.rowgap!(grid, size(grid)[1]-1, Makie.Fixed(0))
        end
    end

    return

end

# These stubs exist to provide Unit support via extension packages.

# Determine the default (not user-provided) label string for a column of this name
# and column type.
function default_label_string(name::Symbol, coltype)
    return string(name)
end
function default_label_string(name::String, coltype)
    return name
end
function ustrip(data)
    return data
end

# Note: stephist coming soon in a Makie PR

function diagplot(ax::Makie.Axis, viz::MarginHist, series::AbstractSeries, colname)
    cn = columnnames(series)
    if colname ∉ cn
        return
    end
    dat = ustrip(disallowmissing(getcolumn(series, colname)))

    if haskey(series.bins, colname)
        bins = series.bins[colname]
    else
        # Determine the number of bins to use, and allow series or
        # visualization layer to override.
        bins = max(7, ceil(Int, 1.8log2(length(dat))) + 1)
        bins = get(series.kwargs, :bins, bins)
        bins = get(viz.kwargs, :bins, bins)
    end
    x, weights = viz.prepare_hist(dat,  bins)

    # This lets one visualize very different scale PDFs on the same plot.
    normalize = true
    if haskey(series.kwargs, :normalize)
        normalize = series.kwargs[:normalize]
    end
    if haskey(viz.kwargs, :normalize)
        normalize = viz.kwargs[:normalize]
    end

    if !normalize
        weights ./= maximum(weights)
    end

    kw = (;
        series.kwargs...,
        viz.kwargs...,
    )
    kw = delete(kw, :normalize)

    Makie.barplot!(
        ax, x, weights;
        gap = 0,
        kw...
    )
    Makie.ylims!(ax,low=0)
end


function diagplot(ax::Makie.Axis, viz::MarginStepHist, series::AbstractSeries, colname)
    cn = columnnames(series)
    if colname ∉ cn
        return
    end
    dat = ustrip(disallowmissing(getcolumn(series, colname)))

    # Determine the number of bins to use, and allow series or
    # visualization layer to override.
    if haskey(series.bins, colname)
        bins = series.bins[colname]
    else
        # Determine the number of bins to use, and allow series or
        # visualization layer to override.
        bins = max(7, ceil(Int, 1.8log2(length(dat))) + 1)
        bins = get(series.kwargs, :bins, bins)
        bins = get(viz.kwargs, :bins, bins)
    end
    x, weights = viz.prepare_hist(dat,  bins)


    # This lets one visualize very different scale PDFs on the same plot.
    normalize = true
    if haskey(series.kwargs, :normalize)
        normalize = series.kwargs[:normalize]
    end
    if haskey(viz.kwargs, :normalize)
        normalize = viz.kwargs[:normalize]
    end

    if !normalize
        weights ./= maximum(weights)
    end

    kw = (;
        series.kwargs...,
        viz.kwargs...,
    )
    kw = delete(kw, :normalize)
    kw = delete(kw, :bins)

    Makie.stairs!(
        ax, x .+ step(x)./2, weights;
        kw...
    )
    Makie.ylims!(ax,low=0)
end

function diagplot(ax::Makie.Axis, viz::MarginDensity, series::AbstractSeries, colname)
    cn = columnnames(series)
    if colname ∉ cn
        return
    end
    # Note: missing already filtered out, this just informs kde() that no missings
    # are present.
    dat = ustrip(disallowmissing(getcolumn(series, colname)))
    # Makie.density!(
    #     ax,
    #     dat;
    #     series.kwargs...,
    #     viz.kwargs...,
    # )

    k  = KernelDensity.kde(dat, bandwidth=KernelDensity.default_bandwidth(dat).*viz.bandwidth)
    ik = KernelDensity.InterpKDE(k)

    exx = extrema(dat)
    N = 100
    x = range(first(exx), last(exx), length=N)
    y = pdf.(Ref(ik), x)


    # Sometimes it is preferable to scale different series so that the the mode has probability unity.
    # This lets one visualize very different scale PDFs on the same plot.
    normalize = true
    if haskey(series.kwargs, :normalize)
        normalize = series.kwargs[:normalize]
    end
    if haskey(viz.kwargs, :normalize)
        normalize = viz.kwargs[:normalize]
    end

    if !normalize
        y ./= maximum(y)
    end

    Makie.lines!(ax, x, y;
        delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
        delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
    )
    Makie.ylims!(ax,low=0)
end


function diagplot(ax::Makie.Axis, viz::MarginConfidenceLimits, series::AbstractSeries, colname)
    cn = columnnames(series)
    if colname ∉ cn
        return
    end
    dat = ustrip(disallowmissing(vec(getcolumn(series, colname))))

    quantiles = quantile(dat, viz.quantiles)
    mid = quantiles[2]
    low = mid - quantiles[1]
    high = quantiles[3] - mid

    title = viz.formatter(low,mid,high)
    prev_title = ax.title[]
    if length(string(prev_title)) > 0
        prev_title = prev_title * " "
    end
    ax.title = Makie.latexstring(prev_title, title)

    Makie.vlines!(
        ax,
        [mid-low, mid, mid+high];
        linestyle=:dash,
        depth_shift=-10f0,
        delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
        delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
    )
end

function diagplot(ax::Makie.Axis, viz::MarginLines, series::AbstractSeries, colname)
    cn = columnnames(series)
    if colname ∉ cn
        return
    end
    dat = getcolumn(series, colname)

    Makie.vlines!(
        ax,
        dat;
        delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
        delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
    )
end


function bodyplot(ax::Makie.Axis, viz::HexBin, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    try
        X = ustrip(disallowmissing(getcolumn(series, colname_col)))
        Y = ustrip(disallowmissing(getcolumn(series, colname_row)))
        # Determine the number of bins to use, and allow series or
        # visualization layer to override.
        bins = max(7, ceil(Int, 1.8log2(length(X))) + 1)
        bins = get(series.kwargs, :bins, bins)
        bins = get(viz.kwargs, :bins, bins)
        Makie.hexbin!(
            ax,
            X,
            Y;
            colormap=Makie.cgrad([:transparent, :black]),
            bins,
            delete(NamedTuple(series.kwargs), :color)...,
            delete(NamedTuple(viz.kwargs), :color)...,
        )
    catch err
        if err isa InexactError
            @warn "InexactError encountered in `hexbin`" colname_row colname_col
        else
            rethrow(err)
        end
    end
end

function bodyplot(ax::Makie.Axis, viz::Hist, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    xdat = getcolumn(series, colname_col)
    ydat = getcolumn(series, colname_row)

    # Determine the number of bins to use, and allow series or
    # visualization layer to override.
    if haskey(series.bins, colname_row)
        xbins = series.bins[colname_row]
    else
        # Determine the number of bins to use, and allow series or
        # visualization layer to override.
        xbins = max(7, ceil(Int, 1.8log2(length(xdat))) + 1)
        xbins = get(series.kwargs, :bins, xbins)
        xbins = get(viz.kwargs, :bins, xbins)
    end
    if haskey(series.bins, colname_col)
        ybins = series.bins[colname_col]
    else
        # Determine the number of bins to use, and allow series or
        # visualization layer to override.
        ybins = max(7, ceil(Int, 1.8log2(length(ydat))) + 1)
        ybins = get(series.kwargs, :bins, ybins)
        ybins = get(viz.kwargs, :bins, ybins)
    end
    x, y, weights = viz.prepare_hist(xdat, ydat, xbins, ybins)

    Makie.heatmap!(
        ax,
        x,
        y,
        weights;
        colormap=Makie.cgrad([:transparent, :black]),
        delete(NamedTuple(series.kwargs), :color)...,
        delete(NamedTuple(viz.kwargs), :color)...,
    )
end

function prep_contours(series::AbstractSeries, sigmas, colname_row, colname_col; bandwidth=1.0)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    xdat = ustrip(disallowmissing(getcolumn(series, colname_col)))
    ydat = ustrip(disallowmissing(getcolumn(series, colname_row)))
    dat = (xdat, ydat)
    k  = KernelDensity.kde(dat, bandwidth=KernelDensity.default_bandwidth(dat).*bandwidth)
    ik = KernelDensity.InterpKDE(k)

    exx = extrema(xdat)
    exy = extrema(ydat)
    N = 100
    x = range(first(exx), last(exx), length=N)
    y = range(first(exy), last(exy), length=N)
    h = pdf.(Ref(ik), x, y')

    # Calculate levels for contours
    levels = 1 .- exp.(-0.5 .* (1 ./sigmas).^2)
    ii = sortperm(reshape(h,:))
    h2flat = h[ii]
    sm = cumsum(h2flat)
    sm /= sm[end]
    if all(isnan, sm) || length(h) <= 1
        @warn "Could not compute valid contours between $colname_col and $colname_row"
        V = [0]
    else
        V = sort(map(v0 -> h2flat[sm .≤ v0][end], levels))
        if any(==(0), diff(V))
            @warn "Too few points to create valid contours"
        end
    end

    # Place a row and column of zeros around all sides of the data grid
    # to ensure the contours link up nicely.
    pad_x = [first(x)-step(x); x; last(x)+step(x)]
    pad_y = [first(y)-step(y); y; last(y)+step(y)]
    pad_h = [
        zeros(size(h,2))' 0 0
        zeros(size(h,1)) h zeros(size(h,1))
        zeros(size(h,2))' 0 0
    ]
    c = ContourLib.contours(pad_x,pad_y,pad_h, V)
    return c
end


const invalid_attrs_lines2 = (:strokewidth, :strokecolor, :normalize)

function bodyplot(ax::Makie.Axis, viz::Contour, series, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    c = prep_contours(series::AbstractSeries, viz.sigmas, colname_row, colname_col; viz.bandwidth)
    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        # Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); strokewidth=2, series.kwargs...,  viz.kwargs..., color=:transparent, strokecolor=color)#(color, i/length(levels)))
        Makie.lines!(
            ax, xs, ys;
            delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
            delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
        )
    end
end

function bodyplot(ax::Makie.Axis, viz::Contourf, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    c = prep_contours(series::AbstractSeries, viz.sigmas, colname_row, colname_col; viz.bandwidth)
    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); series.kwargs..., viz.kwargs...)#(color, 1/length(levels)))
    end
end


function bodyplot(ax::Makie.Axis, viz::Scatter, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    xall = ustrip(disallowmissing(getcolumn(series, colname_col)))
    yall = ustrip(disallowmissing(getcolumn(series, colname_row)))

    if isnothing(viz.filtersigma)
        Makie.scatter!(ax, xall, yall; markersize=1.0, series.kwargs..., viz.kwargs...)
        return
    end

    c = prep_contours(series, [viz.filtersigma], colname_row, colname_col)
    levels = ContourLib.levels(c)
    xfilt, yfilt = scatter_filtering(xall, yall, first(levels))
    Makie.scatter!(ax, xfilt, yfilt; markersize=1.0, series.kwargs..., viz.kwargs...)

end

function bodyplot(ax::Makie.Axis, viz::TrendLine, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    xall = ustrip(disallowmissing(getcolumn(series, colname_col)))
    yall = ustrip(disallowmissing(getcolumn(series, colname_row)))

    if length(xall) == 0
        return
    end

    # Perform a simple linear fit.
    A = [xall ones(length(xall))]
    local m, b
    try
        m, b = A \ yall
    catch err
        if err isa LinearAlgebra.LAPACKException ||
            err isa LinearAlgebra.SingularException
            @error "Could not fit trend line" exception=(err,catch_backtrace())
            return
        else
            rethrow(err)
        end
    end
    Makie.ablines!(
        ax, b, m;
        delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
        delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
    )
    return
end


function PairPlots.bodyplot(ax::Makie.Axis, viz::Calculation, series::AbstractSeries,
    colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∉ cn || colname_col ∉ cn
        return
    end
    X = ustrip(disallowmissing(getcolumn(series, colname_col)))
    Y = ustrip(disallowmissing(getcolumn(series, colname_row)))
    c = viz.f(X, Y)
    @static if VERSION >= v"1.10"
        text = @sprintf("%s = %0.*f", viz.label, viz.digits, c)
    else
        text = @eval @sprintf(
            $("%s = \$%.$(viz.digits)f"),
            viz.label, c
        )
    end
    Makie.text!(
        ax,
        [viz.position];
        text,
        space=:relative, fontsize=10,
        align=(:left, :top),
        viz.kwargs...
    )
    return
end

function bodyplot(ax::Makie.Axis, viz::BodyLines, series::AbstractSeries, colname_row, colname_col)
    cn = columnnames(series)
    if colname_row ∈ cn
        xall = getcolumn(series, colname_row)
        Makie.hlines!(
            ax,xall;
            delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
            delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
        )
    end
    if colname_col ∈ cn
        yall = getcolumn(series, colname_col)
        Makie.vlines!(
            ax,yall;
            delete(NamedTuple(series.kwargs), invalid_attrs_lines2)...,
            delete(NamedTuple(viz.kwargs), invalid_attrs_lines2)...,
        )
    end
end


# Default histogram calculations
"""
    prepare_hist(vector, nbins)

Use the StatsBase function to return a centered histogram from `vector` with `nbins`.
Must return a tuple of bin centres, followed by bin weights (of the same length).
"""
function prepare_hist(a, nbins::Integer)
    h = fit(Histogram, ustrip(disallowmissing(vec(a))); nbins)
    h = normalize(h, mode=:pdf)
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    return x, h.weights
end
function prepare_hist(a, bins::Any)
    h = fit(Histogram, ustrip(disallowmissing(vec(a))), bins;)
    h = normalize(h, mode=:pdf)
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    return x, h.weights
end
"""
    prepare_hist(vector, nbins)

Use the StatsBase function to return a centered histogram from `vector` with `nbins`x`nbins`.
Must return a tuple of bin centres along the horizontal, bin centres along the vertical,
and a matrix of bin weights (of matching dimensions).
"""
function prepare_hist(a, b, nbinsx::Integer, nbinsy::Integer)
    h = fit(Histogram, (ustrip(disallowmissing(vec(a))),ustrip(disallowmissing(vec(b)))); nbins=(nbinsx,nbinsy))
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    y = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))
    return x, y, h.weights
end
function prepare_hist(a, b, xbins::Any, ybins::Any)
    h = fit(Histogram, (ustrip(disallowmissing(vec(a))),ustrip(disallowmissing(vec(b)))), (xbins, ybins))
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    y = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))
    return x, y, h.weights
end



# Filter the scatter plot to remove points inside the first contour
# for performance and better display
function scatter_filtering(x,y, level)

    inds = eachindex(x,y)
    outside = trues(size(inds))

    # calculate the outer contour manually
    for poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        poly = SVector.(xs,ys)
        push!(poly, SVector(xs[begin], ys[begin]))
        # Could benchmark threading this
        for i in inds
            point = SVector(x[i],y[i])
            # This logic does not seem to be 100% right
            ins = inpolygon(point, poly, in=false, on=true, out=true)
            outside[i] &= ins
        end
    end
    return view(x, outside), view(y, outside)

end

# table utils

columnnames(truth::Truth) = keys(truth.table)
getcolumn(truth::Truth, name) = truth.table[name]

columnnames(series::Series) = columnnames(series.table)
getcolumn(series::Series, name) = getcolumn(series.table, name)

function nrows(table)
    cols = Tables.columns(table)
    names = Tables.columnnames(cols)
    isempty(names) && return 0
    length(Tables.getcolumn(cols, first(names)))
end

function columnnames(table)
    cols = Tables.columns(table)
    Tables.columnnames(cols)
end

function getcolumn(table, name)
    cols = Tables.columns(table)
    Tables.getcolumn(cols, name)
end

include("defaults.jl")
include("precompile.jl")

end

