module PairPlots

using RecipesBase
using Measures
using NamedTupleTools
using Tables

using Statistics
using StatsBase

using Printf
using Requires
using StaticArrays
using PolygonOps
using Contour


function corner end
# We pull in Plots only using Requires instead of as a diret dependency, so 
# that upstream packages can add us as a dependency e.g. for visualizing 
# a custom datastructure without needing all of Plots.
# Give the user a helpful error message if they have not imported Plots yet
corner(args...; kwargs...) = error("You must run `using Plots` before using this package.")
export corner

function hist(a, histfunc, hist_kwargs, plotpercentiles, percentiles_kwargs,)

    x, h = histfunc(a, hist_kwargs.nbins)

    if length(x) == 1
        @warn "1D histgoram has only one bin"
        RecipesBase.plot!(; framestyle=:none, title="invalid", hist_kwargs.subplot, hist_kwargs.inset, )
        return
    end

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
    if get(hist_kwargs, :title, "") != ""
        pcs_title = quantile(a_sorted, [0.16, 0.5, 0.84], sorted=true)
        med = pcs_title[2]
        low = med - pcs_title[1]
        high =  pcs_title[3] - med
        title = @sprintf("\$%s = %.2f^{+%.2f}_{-%.2f}\$", hist_kwargs.title, pcs_title[2], high, low)
        xc = mean(x)
        yc = maximum(h_scaled) * 1.15
        hist_kwargs = (;hist_kwargs..., title)
    end
    hist_kwargs = delete(hist_kwargs, :nbins)
    percentiles_kwargs = delete(percentiles_kwargs,:title)
    # p = RecipesBase.plot()

    kw = merge((;seriestype=:step), hist_kwargs)
    if kw.seriestype==:step
        x = x .- step(x)/2
    end
    RecipesBase.plot!(x, h_scaled; kw...)
    # RecipesBase.plot!(x, h_scaled; kw.inset, kw.subplot)
    # RecipesBase.plot!(x, h_scaled; kw.inset, kw.subplot, kw.seriestype, kw.xrotation, kw.yrotation, kw.tick_direction, kw.grid, kw.yformatter, kw.xlims, yticks)

    if length(pcs) > 0
        RecipesBase.plot!(pcs; seriestype=:vline, percentiles_kwargs...)
    end

    # return p
end
function hist(a, b, histfunc, hist2d_kwargs, contour_kwargs, scatter_kwargs, plotcontours, plotscatter, filterscatter)

    x, y, H = histfunc(a, b, hist2d_kwargs.nbins)

    threeD = get(hist2d_kwargs, :seriestype, nothing) == :wireframe

    # Calculate levels for contours
    levels = 1 .- exp.(-0.5 .* (0.5:0.5:2.1).^2)
    ii = sortperm(reshape(H,:))
    h2flat = H[ii]
    sm = cumsum(h2flat)
    sm /= sm[end]
    if all(isnan, sm)
        @warn "Could not compute valid contours"
        plotcontours = false
        V = [0]
    else
        V = sort(map(v0 -> h2flat[sm .≤ v0][end], levels))
        if any(==(0), diff(V))
            @warn "Too few points to create valid contours"
        end
    end

    # # Exclude histogram spaces outside the outer contour
    # masked_weights = fill(NaN, size(H))
    # # # Old method of masking out histogram squares
    # # # if plotscatter && !threeD
    # # #     mask = H .>= V[1]
    # # # else
    # # #     mask = trues(size(H))
    # # # end
    # if plotscatter &&!threeD
    #     mask = H .> V[1]
    # else
    #     mask = trues(size(H))
    # end
    # masked_weights[mask] .= H[mask]
    masked_weights = H

    levels_final = [0; V; maximum(H) * (1 + 1e-4)]

    # p = RecipesBase.plot()
    if threeD
        scatter_kwargs = merge(scatter_kwargs, (; seriestype=:scatter3d))
        # if !hasproperty(contour_kwargs, :seriestype)
        #     contour_kwargs = merge(contour_kwargs, (;seriestype=:contour3d))
        # end
        plotcontours = false
    end
    RecipesBase.plot!(x, y, masked_weights; seriestype=:heatmap, hist2d_kwargs...)

    if plotscatter
        if filterscatter
            points = scatter_filtering(b, a, x,y,H, [V[1]])
        else
            points = (b,a)
        end
        # TODO: handle threeD
        if get(scatter_kwargs, :seriestype, nothing) == :scatter3d
            z = zeros(size(y))
            RecipesBase.plot!(b, a, z; scatter_kwargs...)
        else
            RecipesBase.plot!(points; seriestype=:scatter, scatter_kwargs...)
        end
    end

    if plotcontours
        RecipesBase.plot!(x, y, H; seriestype=:contour, levels=levels_final, colorbar=:none, contour_kwargs...)
        # GR does not yet support transparent filled contours. This would allow us to have even nicer edges to the histogram/contour boundary
        # outer_cmap = cgrad([RGBA(255,255,255,1.0), RGBA(255,255,255,0.0)])
        # RecipesBase.plot!(p, x, y, H; seriestype=:contourf, levels=[0,levels_final[2], levels_final[3]], colorbar=:none, contour_kwargs..., color=outer_cmap)
    end
    # p
end

emptyplot() = RecipesBase.plot(framestyle=:none, background_color_inside=:transparent)

# Default histogram calculations
"""
    prepare_hist(vector, nbins)

Use the StatsBase function to return a centered histogram from `vector` with `nbins`.
Must return a tuple of bin centres, followed by bin weights (of the same length).
"""
function prepare_hist(a, nbins)
    h = fit(Histogram, a; nbins)
    # x = first(only(h.edges))+step(only(h.edges))/2 : step(only(h.edges)) : last(only(h.edges))-step(only(h.edges))/2
    x = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
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
    y = range(first(h.edges[1])+step(h.edges[1])/2, step=step(h.edges[1]), length=size(h.weights,1))
    x = range(first(h.edges[2])+step(h.edges[2])/2, step=step(h.edges[2]), length=size(h.weights,2))
    return x, y, h.weights
end

# Filter the scatter plot to remove points inside the first contour
# for performance and better display
function scatter_filtering(b, a, x,y,H, level)

    inds = eachindex(b,a)
    outside = trues(size(inds))

    # calculate the outer contour manually
    c = contours(x,y,H', level)
    for poly in lines(first(levels(c)))
        xs, ys = coordinates(poly)
        poly = SVector.(xs,ys)
        push!(poly, SVector(xs[begin], ys[begin]))
        # poly = [xs ys; xs[begin] ys[begin]]
        for i in inds
            point = SVector(b[i],a[i])
            ins = inpolygon(point, poly, in=false, on=true, out=true)
            outside[i] &= ins
        end
    end
    return b[outside], a[outside]

end


# Special support for MCMCChains.
# They have additional table fields :iteration and :chain that should not be shown
# by default.
# In future, we might add the ability to colour the output by chain number.
function __init__()
    @require MCMCChains="c7f686f2-ff18-58e9-bc7b-31028e88f75d" begin
        function corner(chains::MCMCChains.Chains, args...; kwargs...)
            props = keys(chains)
            # values = (reshape(chains[prop].data,:) for prop in props)
            values = [vec(chains[prop].data) for prop in props]
            table = namedtuple(props, values)
            return corner(table, args...; kwargs...)
        end
    end

    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("corner.jl")
    
    nothing
end



end # module
