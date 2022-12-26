module PairPlots
Base.Experimental.@optlevel 0

export pairplot, TableSeries, DistSeries

using Makie: Makie
using Tables
using Printf
using Contour: Contour as ContourLib
using Latexify: latexify
using StatsBase: fit, quantile, Histogram, sturges
using Distributions
using OrderedCollections: OrderedDict

#=
Goals:
* Revise interface
* Supoprt multiple chains
* Simpler styling...
* truth values, markers
* Support plotting distributions directly 
* -> MultinomialGaussian fitting for clean ellipses


We have two axes of customization, a bit like grammer of graphics.
We have:
    * data kinds, e.g. mix of Distribution and Table series
    * visualization kinds, e.g. hexbin vs. contour vs...
        * This may in theory vary at each position.


want to kep basic pairplot(chain)
also want 
pairplot(
    PairPlots.Series(chain, color=...),
    PairPlots.Series(chain, color=...),
    PairPlots.Lines((a=1, b=2,)),
    PairPlots.Marker(chain, color=...),
    
)

pairplot(
    Series(chains, color=red, scatter=true, )
)

try to make still work if a series is missing a column.


=#

abstract type AbstractSeries end

struct TableSeries2 <: AbstractSeries
    label
    table
    kwargs
end
TableSeries(data; label=nothing, kwargs...) = TableSeries2(label, data, kwargs)


# TODO: adapt to product_distribution
struct DistSeries2 <: AbstractSeries
    label
    keys
    dist
    kwargs
end
function DistSeries(dists::UnivariateDistribution...; label=nothing, kwargs...)
    keys = Symbol.(string.(1:length(dists)))
    DistSeries(label, keys, dists...; kwargs...)
end
function DistSeries(keys, dists::UnivariateDistribution...; kwargs...)
    DistSeries(keys, product_distribution(dists); kwargs...)
end
function DistSeries(dist::MultivariateDistribution; kwargs...)
    keys = Symbol.(string.(1:length(dist)))
    DistSeries(keys, dist; kwargs...)
end
function DistSeries(keys, dist::MultivariateDistribution; kwargs...)
    if length(keys) != length(dist)
        error("length of keys do not match dimensions of distribution")
    end
    DistSeries2(keys, dist, kwargs)
end
function DistSeries(keys, dist::MultivariateDistribution; kwargs...)
    if length(keys) != length(dist)
        error("length of keys do not match dimensions of distribution")
    end
    DistSeries2(keys, dist, kwargs)
end



# struct ConfidenceLimits6 <: AbstractSeries
#     limits
#     titlefmt
#     kwargs
# end
struct MarginConfidenceLimits <: VizTypeDiag
    titlefmt
    kwargs
end
function MarginConfidenceLimits(titlefmt="\$\\mathrm{%.2f^{+%.2f}_{-%.2f}}\$"; kwargs...)
    return MarginConfidenceLimits(titlefmt, kwargs)
end

# struct Lines1 <: AbstractSeries
#     table
#     kwargs
# end
# Lines = Lines1

# struct Marker1 <: AbstractSeries
#     table
#     kwargs
# end
# Marker = Marker1

## Body 


abstract type VizType end
abstract type VizTypeBody <: VizType end

struct HexBin <: VizTypeBody
    kwargs
end
HexBin(;kwargs...) = HexBin(kwargs)

struct Contour2 <: VizTypeBody
    sigmas
    kwargs
end
Contour2(;sigmas=0.5:0.5:2.1, kwargs...) = Contour2(sigmas, kwargs)

struct Contourf2 <: VizTypeBody
    sigmas
    kwargs
end
Contourf2(;sigmas=0.5:0.5:2.1, kwargs...) = Contourf2(sigmas, kwargs)

struct Scatter <: VizTypeBody
    kwargs
end
Scatter(;kwargs...) = Scatter(kwargs)



## Diagonals

abstract type VizTypeDiag <: VizType end
struct MarginHist <: VizTypeDiag
    kwargs
end
MarginHist(;kwargs...) = MarginHist(kwargs)

struct MarginDensity <: VizTypeDiag
    kwargs
end
MarginDensity(;kwargs...) = MarginDensity(kwargs)


colnames(t::TableSeries2) = Tables.columnnames(t.table)
colnames(t::DistSeries2) = t.keys
colnames(t::MarginConfidenceLimits) = keys(t.limits)
colnames(t::NamedTuple) = keys(t)
colnames(t::AbstractDict) = keys(t)



@nospecialize

GridPosTypes = Union{Figure, GridPosition, GridSubposition}

# Create a pairplot without providing a figure
# @nospecialize 
# function pairplot(
#     bodyplottypes::VizTypeBody,
#     diagplottypes::VizTypeDiag,
#     series::AbstractSeries...;
#     figure=(;),
#     kwargs...,
# )
#     fig = Figure(;figure...)
#     pairplot(fig.layout, bodyplottypes, diagplottypes, series...; kwargs...)
#     return fig
# end

# # Create a pairplot by plotting into a grid position of a figure.
# function pairplot(
#     grid::Makie.GridLayout,
#     bodyplottypes::VizTypeBody,
#     diagplottypes::VizTypeDiag,
#     series::AbstractSeries...;
#     labels = Dict(),
#     units = Dict(),
#     axis=(;)
# )
    
#     # We support multiple series that may have disjoint columns
#     # Get the ordered union of all table columns.
#     columns = unique(Iterators.flatten(map(colnames, series)))

#     # Map of column key to label text. 
#     # By default, just latexify the column key but allow override.
#     label_map = Dict(
#         name => Makie.latexstring("\\mathrm{", latexify(name, env=:raw), "}")
#         for name in columns
#     )
#     label_map = merge(label_map, labels)

#     # Similarly for units. By default empty string, but allow override.
#     units_map = Dict(
#         name => L""
#         for name in columns
#     )
#     units_map = merge(units_map, units)

#     # Rather than computing limits in this version, let's try to rely on 
#     # Makie doing a good job of linking axes.

#     N = length(columns)

#     # Keep lists of axes by row number and by column number.
#     # We'll use these afterwards to link axes together.
#     axes_by_row = Dict{Int,Vector{Axis}}()
#     axes_by_col = Dict{Int,Vector{Axis}}()
#     sizehint!(axes_by_col, N)
#     sizehint!(axes_by_row, N)
    
#     # Build grid of nxn plots
#     for row_ind in 1:N, col_ind in 1:N

#         # TODO: make this optional
#         if row_ind < col_ind
#             continue
#         end
        
#         colname_row = columns[row_ind]
#         colname_col = columns[col_ind]

#         ax = Axis(
#             grid[row_ind, col_ind];
#             ylabel=label_map[colname_row],
#             xlabel=label_map[colname_col],
#             xgridvisible=false,
#             ygridvisible=false,
#             # Ensure any axis title that gets added doesn't break the tight layout
#             alignmode = row_ind == 1 ? Inside() : Makie.Mixed(;left=nothing, right=nothing, bottom=nothing, top=Makie.Protrusion(0.0)),
#             xautolimitmargin=(0f0,0f0),
#             yautolimitmargin=(0f0,0f0),
#             # User options
#             axis...,
#         )

#         axes_by_col[col_ind]= push!(get(axes_by_col, col_ind, Axis[]), ax)
#         if row_ind != col_ind
#             axes_by_row[row_ind]= push!(get(axes_by_row, row_ind, Axis[]), ax)
#         end

#         # For each slot, loop through all series and fill it in accordingly.
#         # We have two slot types: bodyplot, like a 3D histogram, and diagplot, along the diagonal
#         for ser in series
#             cn = colnames(ser)
#             # We only include
#             if colname_row in cn && colname_col in cn
#                 if row_ind == col_ind
#                     # Label(grid[row_ind, col_ind], string(colname_row),
#                     #     halign = :center,
#                     #     valign=:bottom,
#                     #     tellwidth=false,
#                     #     tellheight=false
#                     # )
#                     diagplot(ax, diagplottypes, ser, colname_row)
#                 else
#                     bodyplot(ax, bodyplottypes, ser, colname_row, colname_col)
#                 end
#             end
#         end

#         # Hide labels etc. as needed for a compact view
#         if row_ind < N
#             Makie.hidexdecorations!(ax, grid=false)
#         end
#         if col_ind > 1 || row_ind == 1
#             Makie.hideydecorations!(ax, grid=false)
#         end

#     end

#     # Link all axes
#     for axes in values(axes_by_row)
#         Makie.linkyaxes!(axes...)
#     end
#     for axes in values(axes_by_col)
#         Makie.linkxaxes!(axes...)
#     end

#     Makie.rowgap!(grid, Makie.Fixed(0))
#     Makie.colgap!(grid, Makie.Fixed(0))

#     return

# end
function pairplot(
    pairs::Pair{<:AbstractSeries}...;
    figure=(;),
    kwargs...,
)
    fig = Figure(;figure...)
    pairplot(fig.layout, pairs...; kwargs...)
    return fig
end

# Create a pairplot by plotting into a grid position of a figure.
function pairplot(
    grid::Makie.GridLayout,
    pairs::Pair{<:AbstractSeries}...;
    labels = Dict(),
    units = Dict(),
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
    label_map = merge(label_map, labels)

    # Similarly for units. By default empty string, but allow override.
    units_map = Dict(
        name => L""
        for name in columns
    )
    units_map = merge(units_map, units)

    # Rather than computing limits in this version, let's try to rely on 
    # Makie doing a good job of linking axes.

    N = length(columns)

    # Keep lists of axes by row number and by column number.
    # We'll use these afterwards to link axes together.
    axes_by_row = Dict{Int,Vector{Axis}}()
    axes_by_col = Dict{Int,Vector{Axis}}()
    sizehint!(axes_by_col, N)
    sizehint!(axes_by_row, N)
    
    # Build grid of nxn plots
    for row_ind in 1:N, col_ind in 1:N

        # TODO: make this optional
        if row_ind < col_ind
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
            alignmode = row_ind == 1 ? Inside() : Makie.Mixed(;left=nothing, right=nothing, bottom=nothing, top=Makie.Protrusion(0.0)),
            xautolimitmargin=(0f0,0f0),
            yautolimitmargin=(0f0,0f0),
            # User options
            kw...,
        )

        axes_by_col[col_ind]= push!(get(axes_by_col, col_ind, Axis[]), ax)
        if row_ind != col_ind
            axes_by_row[row_ind]= push!(get(axes_by_row, row_ind, Axis[]), ax)
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

    return

end

# Note: stephist coming soon in a Makie PR

function diagplot(ax::Axis, viz::MarginHist, series_i, series::TableSeries2, colname)
    dat = getproperty(series.table, colname)

    h = Makie.hist!(
        ax,
        dat;
        color=Cycled(series_i),
        series.kwargs...,
        viz.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end

function diagplot(ax::Axis, viz::MarginDensity, series_i, series::TableSeries2, colname)
    dat = getproperty(series.table, colname)

    h = Makie.density!(
        ax,
        dat;
        color=Cycled(series_i),
        series.kwargs...,
        viz.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end


function diagplot(ax::Axis, viz::MarginDensity, series_i, series::DistSeries2, colname)
    col_ind = findfirst(==(colname), series.keys)

    # TODO: temporary: work out a better way
    D = rand(series.dist, 10000)
    dat = view(D, col_ind, :) # the "column" index of the series actually indexes rows here

    h = Makie.density!(
        ax,
        dat;
        color=Cycled(series_i),
        series.kwargs...,
        viz.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end

function diagplot(ax::Axis, viz::MarginConfidenceLimits, series_i, series::TableSeries2, colname)

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
        color=Cycled(series_i),
        depth_shift=-10f0,
        series.kwargs...,
        viz.kwargs...,
    )
end

function bodyplot(ax::Axis, viz::HexBin, series_i, series::TableSeries2, colname_row, colname_col)
    Makie.hexbin!(
        ax,
        getproperty(series.table, colname_col),
        getproperty(series.table, colname_row);
        series.kwargs...,
        viz.kwargs...,
    )
end

function bodyplot(ax::Axis, viz::HexBin, series_i, series::DistSeries2, colname_row, colname_col)

    #TODO
    col_ind = findfirst(==(colname_col), series.keys)
    row_ind = findfirst(==(colname_row), series.keys)

    # TODO: temporary: work out a better way
    D = rand(series.dist, 50000)

    Makie.hexbin!(
        ax,
        view(D, col_ind, :),
        view(D, row_ind, :),;
        series.kwargs...,
        viz.kwargs...,
    )
end

# Given a series and two columns, return a ContourLib.contours object.
function prep_contours(series::TableSeries2, sigmas, colname_row, colname_col)
    h = fit(Histogram, (vec(getproperty(series.table, colname_row)),vec(getproperty(series.table, colname_col))); nbins=get(series.kwargs, :bins, sturges(length(getproperty(series.table, colname_row)))))
    y = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    x = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))
    h = h.weights

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

    pad_x = [first(x)-step(x); x; last(x)+step(x)]
    pad_y = [first(y)-step(y); y; last(y)+step(y)]
    pad_h = [
        zeros(size(h,2))' 0 0
        zeros(size(h,1)) h zeros(size(h,1))
        zeros(size(h,2))' 0 0
    ]
    c = ContourLib.contours(pad_x,pad_y,pad_h', V)
end

function bodyplot(ax::Axis, viz::Contour2, series_i, series, colname_row, colname_col)

    c = prep_contours(series::TableSeries2, viz.sigmas, colname_row, colname_col)
   
    color = get(viz.kwargs, :color, Cycled(series_i))
    color = get(series.kwargs, :color, color)

    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        # Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); strokewidth=2, series.kwargs...,  viz.kwargs..., color=:transparent, strokecolor=color)#(color, i/length(levels)))
        Makie.lines!(ax, xs, ys;series.kwargs...,  viz.kwargs..., color)#(color, i/length(levels)))
    end
end

function bodyplot(ax::Axis, viz::Contourf2, series_i, series::TableSeries2, colname_row, colname_col)

    c = prep_contours(series::TableSeries2, viz.sigmas, colname_row, colname_col)
   
    color = get(viz.kwargs, :color, Cycled(series_i))
    color = get(series.kwargs, :color, color)

    levels = ContourLib.levels(c)
    for (i,level) in enumerate(levels), poly in ContourLib.lines(level)
        xs, ys = ContourLib.coordinates(poly)
        Makie.poly!(ax, Makie.Point2f.(zip(xs,ys)); series.kwargs..., viz.kwargs..., color=color)#(color, 1/length(levels)))
    end
end


function bodyplot(ax::Axis, viz::Scatter, series_i, series::TableSeries2, colname_row, colname_col)

    Makie.scatter!(ax, getproperty(series.table, colname_col), getproperty(series.table, colname_row); series.kwargs..., viz.kwargs...)
end




# Filter the scatter plot to remove points inside the first contour
# for performance and better display
function scatter_filtering(b, a, x,y, level)

    inds = eachindex(b,a)
    outside = trues(size(inds))

    # calculate the outer contour manually
    for poly in lines(level)
        xs, ys = coordinates(poly)
        poly = SVector.(xs,ys)
        push!(poly, SVector(xs[begin], ys[begin]))
        # poly = [xs ys; xs[begin] ys[begin]]
        for i in inds
            point = SVector(b[i],a[i])
            # This logic does not seem to be 100% right
            ins = inpolygon(point, poly, in=false, on=true, out=true)
            outside[i] &= ins
        end
    end
    return b[outside], a[outside]

end

end
