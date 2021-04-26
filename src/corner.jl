using .Plots
function corner(
    table,
    labels = map(string, Tables.columnnames(table));
    title="",
    plotcontours=true,
    plotscatter=true,
    plotpercentiles=[15,50,84],
    histfunc=prepare_hist,
    filterscatter=true,
    hist_kwargs=(;),
    hist2d_kwargs=(;),
    contour_kwargs=(;),
    scatter_kwargs=(;),
    percentiles_kwargs=(;),
    appearance=(;),
    lens=nothing,
    lens_kwargs=(;),
    bonusplot=nothing,


    # By how much should we oversize the limits
    lim_factor = 1.05,

    # Plot layout options (subject to change)
    # Overall plot scale factor
    sf = 1,
    pad_top = 20sf,
    pad_left = 20sf,
    w=40sf,
    h=40sf,
    p=nothing, # 1sf noramlly, 10sf if 3D
    pad_right = 0sf,
    pad_bottom = 10sf,
    pad_bonus = nothing,
    # Remaining kwargs are for the overall plot group
    kwargs...
)


if !Tables.istable(table)
    error("You must supply data in a format consistent with the definition in Tables.jl, e.g. a Named Tuple of vectors.")
end


if any(!isascii, labels)
    @warn "Non-ascii labels detected. Some plotting backends require passing these using LaTeX escapes, e.g. \\alpha instead of α"
end

columns = Tables.columnnames(table)
n = length(columns)

# Merge keywords for different subplots & series
hist_kwargs=merge((; nbins=20, color=:black, yticks=[], minorgrid=false, minorticks=false), hist_kwargs)
hist2d_kwargs=merge((; nbins=32, color=:Greys, colorbar=:none), hist2d_kwargs)
contour_kwargs=merge((; color=:black, linewidth=1.5), contour_kwargs)
scatter_kwargs=merge((; color=:black, alpha=0.1, markersize=1.5, markerstrokewidth=0), scatter_kwargs)
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
    tick_direction=:out,
    label="",
), appearance)

threeD = get(hist2d_kwargs, :seriestype, nothing) == :wireframe
# Increase padding for 3D plots
if isnothing(p)
    p = threeD ? 10sf : 1sf
end

if isnothing(pad_bonus)
    pad_bonus = iseven(n) ? 20sf : 5sf
end

# Calculate a default reasonable size unless overriden
# s = 250*n
# kwargs = merge((;size = (s,s)), kwargs)


# Rather than messing with linking axes, let's just take over setting the plot limits ourselves
# ex = [extrema(Tables.getcolumn(table, i)) for i in 1:n]

ex = [(-5, +5) .* std(Tables.getcolumn(table, i)) for i in 1:n]

mins = [ex[1] for ex in ex]
maxs = [ex[2] for ex in ex]



full_width = (pad_left+(w+p)*n+pad_right)
full_height = (pad_top+(h+p)*n+pad_bottom)
parent = RecipesBase.plot(
    # size=((w+p)*n, ((w+p)*n+pad_top)),
    size=(full_width*4,full_height*4),
    framestyle=:none,
    title=title;
    # left_margin=-10Measures.mm,
    background_color_inside=:transparent,
    kwargs...
)

fmt(label) = "\$$label\$"

# Build grid of nxn plots
k = 1
for row in 1:n, col in 1:n

    if row < col
        # push!(subplots, emptyplot())
        continue
    end
    k+=1


    # fmt(label) = "\$\\mathrm{$label}\$"
    kw = (;
        title = row == col ? labels[row] : "",
        xguide = threeD || row == n ? fmt(labels[col]) : "",
        yguide = col == 1  && row > 1 ? fmt(labels[row]) : "",
        xformatter = threeD || row == n ? appearance.xformatter : t->"",
        yformatter = threeD || col == 1 && row > 1 ? appearance.yformatter : t->"",

        # For crudlely tweaking aspect ratios of the plots to account for
        # top_margin = row == 1 ? 10Measures.mm : :match,
        # left_margin = col == 1 ? 8Measures.mm : :match,
        # right_margin = col == n ? 6Measures.mm : :match,

        xlims=(mins[col], maxs[col]).*lim_factor,
        label="",
        subplot=k,
    )
    x=(col-1)*(w+p)+pad_left
    y=(row-1)*(h+p)+pad_top
    inset = bbox(x*Measures.mm, y*Measures.mm, w*Measures.mm, h*Measures.mm, :left)


    if row != col
        kw = (;kw..., ylims=(mins[row], maxs[row]).*lim_factor)
    end

    # subplot = 
    if row == col
        # 1D histogram
        hist(Tables.getcolumn(table, row), histfunc, merge(appearance, kw, hist_kwargs, (;inset)), plotpercentiles, merge(kw, percentiles_kwargs))
    else row > col
        # 2D histogram 
        hist(Tables.getcolumn(table, row), Tables.getcolumn(table, col), histfunc, merge(appearance, kw, hist2d_kwargs, (;inset)), merge(kw,contour_kwargs), merge(kw,scatter_kwargs), plotcontours, plotscatter, filterscatter)
    end
    # push!(subplots, subplot)
end

if !isnothing(lens)
    k += 1
    nspan = floor(mean(1:n))
    x=nspan*(w+p)+pad_bonus+pad_left
    y=pad_top
    bonuswidth = full_width-x
    bonusheight = full_height-pad_bottom-pad_top-nspan*(h+p) - pad_bonus 
    inset = bbox(x*Measures.mm, y*Measures.mm, bonuswidth*Measures.mm, bonusheight*Measures.mm, :left)
    if lens ∈ columns
        kw = (;label="", subplot=k, title=labels[findfirst(==(lens), columns)])
        hist(Tables.getcolumn(table, lens), histfunc, merge(appearance, kw, hist_kwargs, (;inset), get(lens_kwargs,:hist_kwargs,(;))), plotpercentiles, merge(kw, percentiles_kwargs, get(lens_kwargs,:hist_kwargs,(;))))
    elseif lens[1] ∈ columns && lens[2] ∈ columns
        kw = (;label="", subplot=k, yguide=fmt(labels[findfirst(==(lens[1]), columns)]), xguide=fmt(labels[findfirst(==(lens[2]), columns)]))
        hist(Tables.getcolumn(table, lens[1]), Tables.getcolumn(table, lens[2]), histfunc, merge(appearance, kw, hist2d_kwargs, (;inset), lens_kwargs, get(lens_kwargs,:hist2d_kwargs,(;))), merge(kw,contour_kwargs,get(lens_kwargs,:contour_kwargs,(;))), merge(kw,scatter_kwargs,get(lens_kwargs,:scatter_kwargs,(;))), get(lens_kwargs,:plotcontours,plotcontours), get(lens_kwargs,:plotscatter,plotscatter), get(lens_kwargs,:filterscatter,filterscatter))
    end
elseif !isnothing(bonusplot)
    k += 1
    nspan = floor(mean(1:n))
    x=nspan*(w+p)+pad_bonus+pad_left
    y=pad_top
    bonuswidth = full_width-x-pad_bonus
    bonusheight = full_height-pad_bottom-pad_top-nspan*(h+p) - pad_bonus 
    inset = bbox(x*Measures.mm, y*Measures.mm, bonuswidth*Measures.mm, bonusheight*Measures.mm, :left)
    kw = (;inset,subplot=k)
    bonusplot(kw)
end


return parent
end