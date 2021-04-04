module CornerPlots

using RecipesBase
using Measures
using NamedTupleTools
using Tables

using Statistics
using StatsBase

using Printf
# Notes: density=true requires using StatsPlots

# TODO: hexbin for backends that support it
# TODO: bins

# TODO: levels does not appear right vs corner, check cdf math

# TODO: I think for corner.corner they use a special colormar 
# with filled contours to hide the points inside the contour??

function corner(
        table,
        labels = string.(Tables.columnnames(table));
        plotcontours=true,
        plotdatapoints=true,
        plotpercentiles=[15,50,84],
        hist_kwargs=(;),
        hist2d_kwargs=(;),
        contour_kwargs=(;),
        scatter_kwargs=(;),
        percentiles_kwargs=(;),
        appearance=(;),
        # Remaining kwargs are for the overall plot group
        kwargs...
    )

    columns = Tables.columnnames(table)
    n = length(columns)

    # Merge keywords for different subplots & series
    hist_kwargs=merge((; nbins=20, color=:black), hist_kwargs, (;yticks=[]))
    hist2d_kwargs=merge((; nbins=32, color=:Greys, colorbar=:none), hist2d_kwargs)
    contour_kwargs=merge((; color=:black, linewidth=2), contour_kwargs)
    scatter_kwargs=merge((; color=:black, alpha=0.1, markersize=1.5), scatter_kwargs)
    percentiles_kwargs=merge((;linestyle=:dash, color=:black), percentiles_kwargs)
    appearance = merge((;
        framestyle=:box,
        xrotation = 45,
        yrotation = 45,
        # margin=-6Measures.mm,
        grid=:none,
        xformatter=:plain,
        yformatter=:plain,
        zformatter=t->"",
        titlefontsize=10,
    ), appearance)

    threeD = hasproperty(hist2d_kwargs, :seriestype) && hist2d_kwargs.seriestype == :wireframe

    # Calculate a default reasonable size unless overriden
    s = 250*n
    kwargs = merge((;size = (s,s)), kwargs)

    subplots = []

    # Build grid of nxn plots
    for row in 1:n, col in 1:n

        # fmt(label) = "\$\\mathrm{$label}\$"
        fmt(label) = "\$$label\$"
        kw = (;
            title = row == col ? labels[row] : "",
            xguide = threeD || row == n ? fmt(labels[col]) : "",
            yguide = threeD || col == 1  && row > 1 ? fmt(labels[row]) : "",
            xformatter = threeD || row == n ? appearance.xformatter : t->"",
            yformatter = threeD || col == 1 && row > 1 ? appearance.yformatter : t->"",

            # For crudlely tweaking aspect ratios of the plots to account for
            top_margin = row == 1 ? 10Measures.mm : :match,
            left_margin = col == 1 ? 8Measures.mm : :match,
            right_margin = col == n ? 6Measures.mm : :match,
        )

        subplot = 
        if row == col
            # 1D histogram
            hist(getproperty(table,columns[row]), merge(appearance, kw, hist_kwargs), plotpercentiles, merge(kw, percentiles_kwargs))
        elseif row > col
            # 2D histogram 
            hist(getproperty(table,columns[row]), getproperty(table,columns[col]), merge(appearance, kw, hist2d_kwargs), contour_kwargs, scatter_kwargs, plotcontours, plotdatapoints)
        else
            RecipesBase.plot(framestyle=:none, background_color_inside=:transparent)
        end
        push!(subplots, subplot)
    end

    RecipesBase.plot(subplots...; layout=(n,n), legend=:none, link=:both, kwargs...)
end
export corner


function hist(x, hist_kwargs, plotpercentiles, percentiles_kwargs,)

    h = fit(Histogram, x; hist_kwargs.nbins)
    y = first(only(h.edges))+step(only(h.edges))/2 : step(only(h.edges)) : last(only(h.edges))-step(only(h.edges))/2
    minx, maxx = extrema(x)
    extent = maxx - minx
    h_scaled = h.weights ./ maximum(h.weights) .* extent
    h_scaled .+= minx

    pcs = []
    x_sorted = sort(x)
    if length(plotpercentiles) > 0
        pcs = quantile(x_sorted, plotpercentiles./100, sorted=true)
    end

    # WIP: replace the title with an annotation so that the margins don't get messed up.
    if hasproperty(hist_kwargs, :title) && hist_kwargs.title != ""
        pcs_title = quantile(x_sorted, [0.16, 0.5, 0.84], sorted=true)
        med = pcs_title[2]
        low = med - pcs_title[1]
        high =  pcs_title[3] - med
        # title = @sprintf("\$\\mathrm{%s}  = %.2f^{+%.2f}_{-%.2f}\$", hist_kwargs.title, pcs_title[2], high, low)
        title = @sprintf("\$%s = %.2f^{+%.2f}_{-%.2f}\$", hist_kwargs.title, pcs_title[2], high, low)

        xc = (h.edges[1][end] + h.edges[1][begin])/2
        yc = maximum(h_scaled) * 1.4

        
        if hasproperty(hist_kwargs, :titlefontsize)
            color = :black
            if hasproperty(hist_kwargs, :titlefontcolor)
                color=hist_kwargs.titlefontcolor
            end
            hist_kwargs = merge(
                delete(hist_kwargs,:title),
                (;annotation=(xc, yc, (title, color, hist_kwargs.titlefontsize))),
                # ylims=(NaN, yc*1.1)),
            )
        else
            hist_kwargs = merge(
                delete(hist_kwargs,:title),
                (;annotation=(xc, yc, title)),
                # ylims=(NaN, yc*1.1)),
            )
        end    
    end
    hist_kwargs = delete(hist_kwargs, :nbins)
    percentiles_kwargs = delete(percentiles_kwargs,:title)
    p = RecipesBase.plot()
    if length(pcs) > 0
        RecipesBase.plot!(p, pcs; seriestype=:vline, percentiles_kwargs...)
    end
    kw = merge((;seriestype=:step), hist_kwargs)
    if kw.seriestype==:step
        y = y .- step(y)/2
    end
    RecipesBase.plot!(p, y, h_scaled; seriestype=:step, kw...)
    return p
end
function hist(x, y, hist2d_kwargs, contour_kwargs, scatter_kwargs, plotcontours, plotdatapoints)
    h1 = fit(Histogram, (y,x); hist2d_kwargs.nbins)

    p = RecipesBase.plot()


    if hasproperty(hist2d_kwargs, :seriestype) && hist2d_kwargs.seriestype == :wireframe
        scatter_kwargs = merge(scatter_kwargs, (; seriestype=:scatter3d))
        # if !hasproperty(contour_kwargs, :seriestype)
        #     contour_kwargs = merge(contour_kwargs, (;seriestype=:contour3d))
        # end
        plotcontours = false
    end
    if plotdatapoints
        if hasproperty(scatter_kwargs, :seriestype) && scatter_kwargs.seriestype == :scatter3d
            z = zeros(size(y))
            RecipesBase.plot!(p, y, x, z; scatter_kwargs...)
        else
            RecipesBase.plot!(p, y, x; seriestype=:scatter, scatter_kwargs...)
        end
    end

    h2 = h1
    X = first(h2.edges[1])+step(h2.edges[1])/2 : step(h2.edges[1]) : last(h2.edges[1])-step(h2.edges[1])/2
    Y = first(h2.edges[2])+step(h2.edges[2])/2 : step(h2.edges[2]) : last(h2.edges[2])-step(h2.edges[2])/2

    levels = 1 .- exp.(-0.5 .* (0.5:0.5:2.1).^2)
    ii = sortperm(reshape(h2.weights,:))
    h2flat = h2.weights[ii]
    sm = cumsum(h2flat)
    sm /= sm[end]
    V = sort(map(v0 -> h2flat[sm .≤ v0][end], levels))

    if any(==(0), diff(V))
        @warn "Too few points to create valid contours"
    end

    masked_weights = fill(NaN, size(h2.weights))
    if plotdatapoints
        mask = h2.weights .>= V[1]
    else
        mask = trues(size(h2.weights))
    end
    masked_weights[mask] .= h2.weights[mask]

    levels_final = [0; V; maximum(h2.weights) * (1 + 1e-4)]

    RecipesBase.plot!(p, X, Y, masked_weights'; seriestype=:heatmap, hist2d_kwargs...)

    if plotcontours
        RecipesBase.plot!(p, X, Y, h2.weights'; seriestype=:contour, levels=levels_final, colorbar=:none, contour_kwargs...)
        # RecipesBase.plot!(p, X, Y, h2.weights'; linewidth=0, seriestype=:contourf, levels=levels_final, colorbar=:none, contour_kwargs...)
    end

    p
end

# function coords_from_mask(mask)
#     c = count(mask)
#     xs = Vector{Int}(undef, c)
#     ys = Vector{Int}(undef, c)
#     k = 0
#     for i in axes(mask,1), j in axes(mask,2)
#         if mask[i,j]
#             k += 1
#             xs[k] = i
#             ys[k] = j
#         end
#     end
#     return xs, ys
# end

# Precompile statements
# precompile(corner, (NamedTuple{(:a, :b), Tuple{Vector{Float64}, Vector{Float64}}},))

end # module
