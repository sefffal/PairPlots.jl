module PairPlots

using RecipesBase
using Measures
using NamedTupleTools
using Tables

using Statistics
using StatsBase

using Printf

function corner(
        table,
        labels = string.(Tables.columnnames(table));
        plotcontours=true,
        plotscatter=true,
        plotpercentiles=[15,50,84],
        histfunc=prepare_hist,
        hist_kwargs=(;),
        hist2d_kwargs=(;),
        contour_kwargs=(;),
        scatter_kwargs=(;),
        percentiles_kwargs=(;),
        appearance=(;),
        # Remaining kwargs are for the overall plot group
        kwargs...
    )

    # Simple error check to see if the user has imported a plotting package...
    if !hasmethod(RecipesBase.plot, ())
        error("You must run `using Plots` before calling this function")
    end

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
            hist(getproperty(table,columns[row]), histfunc, merge(appearance, kw, hist_kwargs), plotpercentiles, merge(kw, percentiles_kwargs))
            # RecipesBase.plot(framestyle=:none, background_color_inside=:transparent)
        elseif row > col
            # 2D histogram 
            hist(getproperty(table,columns[row]), getproperty(table,columns[col]), histfunc, merge(appearance, kw, hist2d_kwargs), contour_kwargs, scatter_kwargs, plotcontours, plotscatter)
        else
            RecipesBase.plot(framestyle=:none, background_color_inside=:transparent)
        end
        push!(subplots, subplot)
    end

    RecipesBase.plot(subplots...; layout=(n,n), legend=:none, kwargs...)
end
export corner

function hist(a, histfunc, hist_kwargs, plotpercentiles, percentiles_kwargs,)

    x, h = histfunc(a, hist_kwargs.nbins)


    minx, maxx = extrema(a)
    extent = maxx - minx
    # h_scaled = h ./ maximum(h) .* extent
    # h_scaled .+= minx
    h_scaled = h
    pcs = []
    a_sorted = sort(a)
    if length(plotpercentiles) > 0
        pcs = quantile(a_sorted, plotpercentiles./100, sorted=true)
    end
    # WIP: replace the title with an annotation so that the margins don't get messed up.
    if hasproperty(hist_kwargs, :title) && hist_kwargs.title != ""
        pcs_title = quantile(a_sorted, [0.16, 0.5, 0.84], sorted=true)
        med = pcs_title[2]
        low = med - pcs_title[1]
        high =  pcs_title[3] - med
        title = @sprintf("\$%s = %.2f^{+%.2f}_{-%.2f}\$", hist_kwargs.title, pcs_title[2], high, low)
        xc = mean(x)
        yc = maximum(h_scaled) * 1.25
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
        x = x .- step(x)/2
    end
    RecipesBase.plot!(p, x, h_scaled; seriestype=:step, kw...)
    return p
end
function hist(a, b, histfunc, hist2d_kwargs, contour_kwargs, scatter_kwargs, plotcontours, plotscatter)

    x, y, H = histfunc(a, b, hist2d_kwargs.nbins)
    
    p = RecipesBase.plot()
    threeD = hasproperty(hist2d_kwargs, :seriestype) && hist2d_kwargs.seriestype == :wireframe
    if hasproperty(hist2d_kwargs, :seriestype) && hist2d_kwargs.seriestype == :wireframe
        scatter_kwargs = merge(scatter_kwargs, (; seriestype=:scatter3d))
        # if !hasproperty(contour_kwargs, :seriestype)
        #     contour_kwargs = merge(contour_kwargs, (;seriestype=:contour3d))
        # end
        plotcontours = false
    end
    if plotscatter
        if hasproperty(scatter_kwargs, :seriestype) && scatter_kwargs.seriestype == :scatter3d
            z = zeros(size(y))
            RecipesBase.plot!(p, b, a, z; scatter_kwargs...)
        else
            RecipesBase.plot!(p, b, a; seriestype=:scatter, scatter_kwargs...)
        end
    end

    levels = 1 .- exp.(-0.5 .* (0.5:0.5:2.1).^2)
    ii = sortperm(reshape(H,:))
    h2flat = H[ii]
    sm = cumsum(h2flat)
    sm /= sm[end]
    V = sort(map(v0 -> h2flat[sm .≤ v0][end], levels))
    if any(==(0), diff(V))
        @warn "Too few points to create valid contours"
    end
    masked_weights = fill(NaN, size(H))
    if plotscatter && !threeD
        mask = H .>= V[1]
    else
        mask = trues(size(H))
    end
    masked_weights[mask] .= H[mask]
    levels_final = [0; V; maximum(H) * (1 + 1e-4)]
    RecipesBase.plot!(p, x, y, masked_weights; seriestype=:heatmap, hist2d_kwargs...)
    if plotcontours
        RecipesBase.plot!(p, x, y, H; seriestype=:contour, levels=levels_final, colorbar=:none, contour_kwargs...)
    end
    p
end

# Default histogram calculations
"""
    prepare_hist(vector, nbins)

Use the StatsBase function to return a centered histogram from `vector` with `nbins`.
Must return a tuple of bin centres, followed by bin weights (of the same length).
"""
function prepare_hist(a, nbins)
    h = fit(Histogram, a; nbins)
    x = first(only(h.edges))+step(only(h.edges))/2 : step(only(h.edges)) : last(only(h.edges))-step(only(h.edges))/2
    return x, h.weights
end
"""
    prepare_hist(vector, nbins)

Use the StatsBase function to return a centered histogram from `vector` with `nbins`x`nbins`.
Must return a tuple of bin centres along the horizontal, bin centres along the vertical,
and a matrix of bin weights (of matching dimensions).
"""
function prepare_hist(a, b, nbins)
    h = fit(Histogram, (a,b); nbins)
    y = range(first(h.edges[1]), step=step(h.edges[1]), length=size(h.weights,1))
    x = range(first(h.edges[2]), step=step(h.edges[2]), length=size(h.weights,2))
    return x, y, h.weights
end





end # module
