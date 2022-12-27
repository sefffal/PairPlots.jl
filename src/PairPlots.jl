module PairPlots
Base.Experimental.@optlevel 0

export pairplot

using Makie: Makie
using Tables
using Printf
using KernelDensity: KernelDensity
using Contour: Contour as ContourLib
using Latexify: latexify
using StatsBase: fit, quantile, Histogram
using Distributions: pdf
using StaticArrays
using PolygonOps

abstract type AbstractSeries end

struct Series <: AbstractSeries
    label
    table
    kwargs
end
Series(data; label=nothing, kwargs...) = Series(label, data, kwargs)


abstract type VizType end
abstract type VizTypeBody <: VizType end

struct HexBin <: VizTypeBody
    kwargs
end
HexBin(;kwargs...) = HexBin(kwargs)

struct Hist <: VizTypeBody
    kwargs
end
Hist(;kwargs...) = Hist(kwargs)

struct Contour <: VizTypeBody
    sigmas
    kwargs
end
Contour(;sigmas=0.5:0.5:2.1, kwargs...) = Contour(sigmas, kwargs)

struct Contourf <: VizTypeBody
    sigmas
    kwargs
end
Contourf(;sigmas=0.5:0.5:2.1, kwargs...) = Contourf(sigmas, kwargs)

struct Scatter <: VizTypeBody
    kwargs
    filtersigma
end
Scatter(;filtersigma=nothing, kwargs...) = Scatter(kwargs, filtersigma)


## Diagonals

abstract type VizTypeDiag <: VizType end

struct MarginConfidenceLimits <: VizTypeDiag
    titlefmt
    kwargs
end
function MarginConfidenceLimits(titlefmt="\$\\mathrm{%.2f^{+%.2f}_{-%.2f}}\$"; kwargs...)
    return MarginConfidenceLimits(titlefmt, kwargs)
end

struct MarginHist <: VizTypeDiag
    kwargs
end
MarginHist(;kwargs...) = MarginHist(kwargs)

struct MarginDensity <: VizTypeDiag
    kwargs
end
MarginDensity(;kwargs...) = MarginDensity(kwargs)


colnames(t::Series) = Tables.columnnames(t.table)
colnames(t::MarginConfidenceLimits) = keys(t.limits)
colnames(t::NamedTuple) = keys(t)
colnames(t::AbstractDict) = keys(t)


GridPosTypes = Union{Makie.Figure, Makie.GridPosition, Makie.GridSubposition}


function pairplot(
    @nospecialize input...;
    figure=(;),
    kwargs...,
)
    N = length(input)+1
    fig = Makie.Figure(;
        resolution=(300N, 300N),
        figure...
    )
    pairplot(fig.layout, input...; kwargs...)
    return fig
end

# Fallback defaults for convenience
function pairplot(
    grid::Makie.GridLayout,
    @nospecialize datapairs::Any...;
    kwargs...,
)
    # Default to grayscale for a single series
    TS = if length(datapairs) <= 1
        dat -> Series(dat; color=Makie.RGBA(0., 0., 0., 0.5))
    else
        dat -> Series(dat)
    end
    defaults((data,vizlayers)::Pair) = TS(data) => vizlayers
    defaults(data::Any) = TS(data) => (
        PairPlots.HexBin(colormap=Makie.cgrad([:transparent, :black]),bins=32),
        PairPlots.Scatter(filtersigma=0.5), 
        PairPlots.Contour(),
        PairPlots.MarginDensity(
            color=:transparent,
            strokecolor=:black,
            strokewidth=1.5f0
        ),
        PairPlots.MarginConfidenceLimits()
    )

    seriespairs = map(defaults, datapairs)
    pairplot(grid, seriespairs...; kwargs...)
    return
end

# Create a pairplot by plotting into a grid position of a figure.
function pairplot(
    grid::Makie.GridLayout,
    @nospecialize pairs::Pair{<:AbstractSeries}...;
    labels::AbstractDict{Symbol} = Dict{Symbol,Any}(),
    units::AbstractDict{Symbol} = Dict{Symbol,Any}(),
    diagaxis=(;),
    bodyaxis=(;),
)
    # We support multiple series that may have disjoint columns
    # Get the ordered union of all table columns.
    columns = unique(Iterators.flatten(Iterators.map(colnames∘first, pairs)))

    # Map of column key to label text. 
    # By default, just latexify the column key but allow override.
    label_map = Dict(
        name => Makie.latexstring("\\mathrm{", latexify(name, env=:raw), "}")
        for name in columns
    )
    label_map = merge(label_map, Dict(labels))

    # Similarly for units. By default empty string, but allow override.
    units_map = Dict(
        name => Makie.L""
        for name in columns
    )
    units_map = merge(units_map, units)

    # Rather than computing limits in this version, let's try to rely on 
    # Makie doing a good job of linking axes.

    N = length(columns)

    # Keep lists of axes by row number and by column number.
    # We'll use these afterwards to link axes together.
    axes_by_row = Dict{Int,Vector{Makie.Axis}}()
    axes_by_col = Dict{Int,Vector{Makie.Axis}}()
    sizehint!(axes_by_col, N)
    sizehint!(axes_by_row, N)

    # Check if there are any diagonal vizualization layers
    anydiag_viz = mapreduce((|), pairs, init=false) do (series, vizlayers)
        any(v->isa(v, VizTypeDiag), vizlayers)
    end
    
    # Build grid of nxn plots
    for row_ind in 1:N, col_ind in 1:N

        # TODO: make this first condition optional to enable a full grid
        # Also skip diagonals if no diagonal viz layers
        if row_ind < col_ind || !anydiag_viz
            continue
        end
        
        colname_row = columns[row_ind]
        colname_col = columns[col_ind]

        if row_ind == col_ind
            kw = diagaxis
        else
            kw = bodyaxis
        end
        ax = Makie.Axis(
            grid[row_ind, col_ind];
            ylabel=label_map[colname_row],
            xlabel=label_map[colname_col],
            xgridvisible=false,
            ygridvisible=false,
            # Ensure any axis title that gets added doesn't break the tight layout
            alignmode = row_ind == 1 ? Makie.Inside() : Makie.Mixed(;left=nothing, right=nothing, bottom=nothing, top=Makie.Protrusion(0.0)),
            xautolimitmargin=(0f0,0f0),
            yautolimitmargin= row_ind == col_ind ? (0f0, 0.05f0) : (0f0,0f0),
            # User options
            kw...,
        )

        axes_by_col[col_ind]= push!(get(axes_by_col, col_ind, Makie.Axis[]), ax)
        if row_ind != col_ind
            axes_by_row[row_ind]= push!(get(axes_by_row, row_ind, Makie.Axis[]), ax)
        end

        # For each slot, loop through all series and fill it in accordingly.
        # We have two slot types: bodyplot, like a 3D histogram, and diagplot, along the diagonal
        for (series_i,(series, vizlayers)) in enumerate(pairs)
            cn = colnames(series)
            if colname_row in cn && colname_col in cn
                for vizlayer in vizlayers    
                    if row_ind == col_ind && vizlayer isa VizTypeDiag
                        diagplot(ax, vizlayer, series_i, series, colname_row)
                    elseif row_ind != col_ind && vizlayer isa VizTypeBody
                        bodyplot(ax, vizlayer, series_i, series, colname_row, colname_col)
                    else
                        # skip
                    end
                end
            end
        end

        # Hide labels etc. as needed for a compact view
        if row_ind < N
            Makie.hidexdecorations!(ax, grid=false)
        end
        if col_ind > 1 || row_ind == 1
            Makie.hideydecorations!(ax, grid=false)
        end

    end

    # Link all axes
    for axes in values(axes_by_row)
        Makie.linkyaxes!(axes...)
    end
    for axes in values(axes_by_col)
        Makie.linkxaxes!(axes...)
    end

    Makie.rowgap!(grid, Makie.Fixed(0))
    Makie.colgap!(grid, Makie.Fixed(0))

    # We sometimes end up with an extra first row if there are no diagonal vizualization layers
    Makie.trim!(grid)

    return

end

# Note: stephist coming soon in a Makie PR

function diagplot(ax::Makie.Axis, viz::MarginHist, series_i, series::Series, colname)
    dat = getproperty(series.table, colname)

    h = Makie.hist!(
        ax,
        dat;
        color=Makie.Cycled(series_i),
        series.kwargs...,
        viz.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end

function diagplot(ax::Makie.Axis, viz::MarginDensity, series_i, series::Series, colname)
    dat = getproperty(series.table, colname)

    h = Makie.density!(
        ax,
        dat;
        color=Makie.Cycled(series_i),
        series.kwargs...,
        viz.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end


function diagplot(ax::Makie.Axis, viz::MarginConfidenceLimits, series_i, series::Series, colname)

    percentiles = quantile(vec(getproperty(series.table, colname)), (0.16, 0.5, 0.84))
    mid = percentiles[2]
    low = mid - percentiles[1]
    high = percentiles[3] - mid

    title = @eval (@sprintf($(viz.titlefmt), $mid, $high, $low))
    ax.title = Makie.latexstring(ax.title[], title)

    Makie.vlines!(
        ax,
        [mid-low, mid, mid+high];
        linestyle=:dash,
        color=Makie.Cycled(series_i),
        depth_shift=-10f0,
        series.kwargs...,
        viz.kwargs...,
    )
end

function bodyplot(ax::Makie.Axis, viz::HexBin, series_i, series::Series, colname_row, colname_col)
    Makie.hexbin!(
        ax,
        getproperty(series.table, colname_col),
        getproperty(series.table, colname_row);
        bins=32,
        colormap=Makie.cgrad([:transparent, :black]),
        series.kwargs...,
        viz.kwargs...,
    )
end

function bodyplot(ax::Makie.Axis, viz::Hist, series_i, series::Series, colname_row, colname_col)

    xdat = getproperty(series.table, colname_col)
    ydat = getproperty(series.table, colname_row)

    
    bins = get(series.kwargs, :bins, 32)
    bins = get(viz.kwargs, :bins, bins)

    h = fit(Histogram, (vec(xdat),vec(ydat)); nbins=bins)
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    y = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))

    Makie.heatmap!(
        ax,
        x,
        y,
        h.weights;
        colormap=Makie.cgrad([:transparent, :black]),
        series.kwargs...,
        viz.kwargs...,
    )
end

function prep_contours(series::Series, sigmas, colname_row, colname_col)

    xdat = getproperty(series.table, colname_col)
    ydat = getproperty(series.table, colname_row)
    k  = KernelDensity.kde((xdat, ydat))
    ik = KernelDensity.InterpKDE(k)

    exx = extrema(xdat)
    exy = extrema(ydat)
    N = 100
    x = range(first(exx), last(exx), length=N)
    y = range(first(exy), last(exy), length=N)
    h = pdf.(Ref(ik), x, y')
    
    # Calculate levels for contours
    levels = 1 .- exp.(-0.5 .* (sigmas).^2)
    ii = sortperm(reshape(h,:))
    h2flat = h[ii]
    sm = cumsum(h2flat)
    sm /= sm[end]
    if all(isnan, sm) || length(h) <= 1
        @warn "Could not compute valid contours"
        plotcontours = false
        V = [0]
    else
        V = sort(map(v0 -> h2flat[sm .≤ v0][end], levels))
        if any(==(0), diff(V))
            @warn "Too few points to create valid contours"
        end
    end
    levels_final = [0; V; maximum(h) * (1 + 1e-4)]

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
end


function bodyplot(ax::Makie.Axis, viz::Contour, series_i, series, colname_row, colname_col)

    c = prep_contours(series::Series, viz.sigmas, colname_row, colname_col)
   
    color = get(series.kwargs, :color, Makie.Cycled(series_i))
    color = get(viz.kwargs, :color, color)

    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        # Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); strokewidth=2, series.kwargs...,  viz.kwargs..., color=:transparent, strokecolor=color)#(color, i/length(levels)))
        Makie.lines!(ax, xs, ys; strokewidth=1.5, series.kwargs...,  viz.kwargs..., color)
    end
end

function bodyplot(ax::Makie.Axis, viz::Contourf, series_i, series::Series, colname_row, colname_col)

    c = prep_contours(series::Series, viz.sigmas, colname_row, colname_col)
   
    color = get(series.kwargs, :color, Makie.Cycled(series_i))
    color = get(viz.kwargs, :color, color)

    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); series.kwargs..., viz.kwargs..., color=color)#(color, 1/length(levels)))
    end
end


function bodyplot(ax::Makie.Axis, viz::Scatter, series_i, series::Series, colname_row, colname_col)

    xall = getproperty(series.table, colname_col)
    yall = getproperty(series.table, colname_row)

    if isnothing(viz.filtersigma)
        Makie.scatter!(ax, xall, yall; markersize=1f0, series.kwargs..., viz.kwargs...)
        return
    end

    c = prep_contours(series, [viz.filtersigma], colname_row, colname_col)
    levels = ContourLib.levels(c)
    xfilt, yfilt = scatter_filtering(xall, yall, first(levels))
    Makie.scatter!(ax, xfilt, yfilt; markersize=1f0, series.kwargs..., viz.kwargs...)

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

include("precompile.jl")

end

