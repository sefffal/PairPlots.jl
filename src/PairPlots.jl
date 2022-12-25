module PairPlots
Base.Experimental.@optlevel 0

export pairplot, TableSeries, ConfidenceLimits

using Makie: Makie
using Tables
using Printf
using Latexify: latexify
using StatsBase: fit, quantile, Histogram, sturges
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


struct TableSeries1 <: AbstractSeries
    table
    kwargs
end
TableSeries(data; kwargs...) = TableSeries1(data, kwargs)


# """

# - table: Data table
# - labels: Vector of labels for each column.
# - units: Vector of units for each column.
# - kwargs: Keyword arguments to forward to the plotting library
# """
# function series( 
#     table, 
#     # labels = latexify.(Tables.columnnames(table), env=:raw), 
#     # units  = ["" for _ in labels]; 
#     kwargs...
# )
#     if Tables.istable(table)
#         TableSeries1(table; kwargs)
#     elseif 
#     Series2(table, labels, units; kwargs...)
# end

struct ConfidenceLimits6 <: AbstractSeries
    limits
    titlefmt
    kwargs
end
function ConfidenceLimits(table, fmt_str="\$\\mathrm{%.2f^{+%.2f}_{-%.2f}}\$"; kwargs...)
    cn = colnames(table)
    limits = map(cn) do colname
        percentiles = quantile(vec(table[colname]), (0.16, 0.5, 0.84))
        cen = percentiles[2]
        low = cen - percentiles[1]
        high = percentiles[3] - cen
        colname => (low, cen, high)
    end
    return ConfidenceLimits6(OrderedDict(limits), fmt_str, kwargs)
end

struct Lines1 <: AbstractSeries
    table
    kwargs
end
Lines = Lines1

struct Marker1 <: AbstractSeries
    table
    kwargs
end
Marker = Marker1


abstract type VizType end
abstract type VizTypeBody <: VizType end

struct HexBin <: VizTypeBody
    kwargs
end
HexBin(;kwargs...) = HexBin(kwargs)

struct Contour1 <: VizTypeBody
    kwargs
end
Contour1(;kwargs...) = Contour1(kwargs)

struct Contourf1 <: VizTypeBody
    kwargs
end
Contourf1(;kwargs...) = Contourf1(kwargs)


## Diagonals

abstract type VizTypeDiag <: VizType end
struct Hist1D <: VizTypeDiag
    kwargs
end
Hist1D(;kwargs...) = Hist1D(kwargs)

struct Density1 <: VizTypeDiag
    kwargs
end
Density1(;kwargs...) = Density1(kwargs)


colnames(t::TableSeries1) = Tables.columnnames(t.table)
colnames(t::ConfidenceLimits6) = keys(t.limits)
colnames(t::NamedTuple) = keys(t)
colnames(t::AbstractDict) = keys(t)



@nospecialize

GridPosTypes = Union{Figure, GridPosition, GridSubposition}

# Create a pairplot without providing a figure
# @nospecialize 
function pairplot(
    bodyplottypes::VizTypeBody,
    diagplottypes::VizTypeDiag,
    series::AbstractSeries...;
    figure=(;),
    kwargs...,
)
    fig = Figure(;figure...)
    pairplot(fig.layout, bodyplottypes, diagplottypes, series...; kwargs...)
    return fig
end

# Create a pairplot by plotting into a grid position of a figure.
function pairplot(
    grid::Makie.GridLayout,
    bodyplottypes::VizTypeBody,
    diagplottypes::VizTypeDiag,
    series::AbstractSeries...;
    labels = Dict(),
    units = Dict(),
    axis=(;)
)
    
    # We support multiple series that may have disjoint columns
    # Get the ordered union of all table columns.
    columns = unique(Iterators.flatten(map(colnames, series)))

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

        ax = Axis(
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
            axis...,
        )

        axes_by_col[col_ind]= push!(get(axes_by_col, col_ind, Axis[]), ax)
        if row_ind != col_ind
            axes_by_row[row_ind]= push!(get(axes_by_row, row_ind, Axis[]), ax)
        end

        # For each slot, loop through all series and fill it in accordingly.
        # We have two slot types: bodyplot, like a 3D histogram, and diagplot, along the diagonal
        for ser in series
            cn = colnames(ser)
            # We only include
            if colname_row in cn && colname_col in cn
                if row_ind == col_ind
                    # Label(grid[row_ind, col_ind], string(colname_row),
                    #     halign = :center,
                    #     valign=:bottom,
                    #     tellwidth=false,
                    #     tellheight=false
                    # )
                    diagplot(ax, diagplottypes, ser, colname_row)
                else
                    bodyplot(ax, bodyplottypes, ser, colname_row, colname_col)
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

function diagplot(ax::Axis, viz::Hist1D, series::TableSeries1, colname)
    dat = series.table[colname]

    h = Makie.hist!(
        ax,
        dat;
        color=:gray,
        viz.kwargs...,
        series.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end

function diagplot(ax::Axis, viz::Density1, series::TableSeries1, colname)
    dat = series.table[colname]

    h = Makie.density!(
        ax,
        dat;
        color=:gray,
        viz.kwargs...,
        series.kwargs...,
    )
    Makie.ylims!(ax,low=0)
end
function diagplot(ax::Axis, viz::Any, series::ConfidenceLimits6, colname)
    low, mid, high = series.limits[colname]

    title = @eval (@sprintf($(series.titlefmt), $mid, $high, $low))
    ax.title = Makie.latexstring(ax.title[], title)


    Makie.vlines!(
        ax,
        [mid-low, mid, mid+high];
        linestyle=:dash,
        color=:black,
        viz.kwargs...,
        series.kwargs...,
    )
end

function bodyplot(ax::Axis, viz::HexBin, series::TableSeries1, colname_row, colname_col)
    Makie.hexbin!(
        ax,
        series.table[colname_col],
        series.table[colname_row];
        viz.kwargs...,
        series.kwargs...,
    )
end

function bodyplot(ax::Axis, viz::Contour1, series::TableSeries1, colname_row, colname_col)

    h = fit(Histogram, (vec(series.table[colname_row]),vec(series.table[colname_col])); nbins=get(series.kwargs, :bins, sturges(length(series.table[colname_row]))))
    y = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    x = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))

    Makie.contour!(ax, x, y, transpose(h.weights); viz.kwargs..., series.kwargs...)
end

function bodyplot(ax::Axis, viz::Contourf1, series::TableSeries1, colname_row, colname_col)

    h = fit(Histogram, (vec(series.table[colname_row]),vec(series.table[colname_col])); nbins=get(series.kwargs, :bins, sturges(length(series.table[colname_row]))))
    y = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    x = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))

    Makie.contourf!(ax, x, y, transpose(h.weights); interpolate=false, viz.kwargs..., series.kwargs...)
end


function bodyplot(ax::Axis, viz::Any, series::ConfidenceLimits6, colname_row, colname_col)
    # No-op
end

#####

# # Default histogram calculations
# """
#     prepare_hist(vector, nbins)

# Use the StatsBase function to return a centered histogram from `vector` with `nbins`.
# Must return a tuple of bin centres, followed by bin weights (of the same length).
# """
# function prepare_hist(a, nbins)
#     h = fit(Histogram, vec(a); nbins)
#     x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
#     return x, h.weights
# end
# """
#     prepare_hist(vector, nbins)

# Use the StatsBase function to return a centered histogram from `vector` with `nbins`x`nbins`.
# Must return a tuple of bin centres along the horizontal, bin centres along the vertical,
# and a matrix of bin weights (of matching dimensions).
# """
# function prepare_hist(a, b, nbins)
#     h = fit(Histogram, (vec(a),vec(b)); nbins)
#     y = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
#     x = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))
#     return x, y, h.weights
# end

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
