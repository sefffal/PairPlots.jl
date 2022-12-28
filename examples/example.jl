using GLMakie, PairPlots, Distributions


# Generate some data to visualize
N = 100_000
a = [2randn(N÷2) .+ 6; randn(N÷2)]
b = [3randn(N÷2); 2randn(N÷2)]
c = randn(N)
d = c .+ 0.6randn(N)

# Pass data in a format compatible with Tables.jl
# Here, simply a named tuple of vectors.
table = (;a, b, c, d)

##

pairplot(table)


## Logo
N = 400_000
a = randn(N)
b = randn(N)
c = randn(N)
table = (;a,b,c)

for cname in (:green,:red,:purple)
    color = getproperty(Makie.Colors.JULIA_LOGO_COLORS, cname)
    fig = pairplot(
        table => (
            PairPlots.HexBin(colormap=Makie.cgrad([:transparent, color]),bins=32),
            PairPlots.Scatter(filtersigma=2,color=color), 
            PairPlots.Contour(),
            PairPlots.MarginDensity(
                color=:transparent,
                strokecolor=color,
                strokewidth=1.5f0
            )
        ),
        bodyaxis=(;
            xlabelvisible=false,
            xticksvisible=false,
            xticklabelsvisible=false,
            ylabelvisible=false,
            yticksvisible=false,
            yticklabelsvisible=false,
        ),
        diagaxis=(;
            xlabelvisible=false,
            xticksvisible=false,
            xticklabelsvisible=false,
            ylabelvisible=false,
            yticksvisible=false,
            yticklabelsvisible=false,
        ),
    )
    rowgap!(fig.layout,0.0)
    colgap!(fig.layout,0.0)
    save("logo-$cname.png", fig)
end

