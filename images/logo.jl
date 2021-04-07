using Plots, PairPlots
using Colors

##
N = 400_000
a = randn(N)
b = randn(N)
c = randn(N)
data = (;a,b,c)

##
for cname in (:green,:red,:purple)
    color = getproperty(Colors.JULIA_LOGO_COLORS, cname)
    corner(
        data,
        plotpercentiles=[],
        hist2d_kwargs=(;color, nbins=45, xguide="", yguide="", xticks=[], yticks=[]),
        contour_kwargs=(; xguide="", yguide="", xticks=[], yticks=[]),
        scatter_kwargs=(;color, alpha=0.1, xguide="", yguide="", xticks=[], yticks=[]),
        hist_kwargs=(;title="",xticks=[])
    )
    savefig("images/logo-$cname.png")
end