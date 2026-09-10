using Test
using Makie
using Tables
using PairPlots

struct CustomTable{T<:NamedTuple}
    data::T
end

Tables.istable(::Type{<:CustomTable}) = true
Tables.columnaccess(::Type{<:CustomTable}) = true
Tables.columns(t::CustomTable) = t
Tables.columnnames(t::CustomTable) = keys(t.data)
Tables.getcolumn(t::CustomTable, i::Int) = t.data[i]
Tables.getcolumn(t::CustomTable, nm::Symbol) = t.data[nm]
Tables.schema(t::CustomTable) = Tables.schema(t.data)

@testset "Basic functionality" begin
    
    table = (;
        # These are just from randn(100) but don't actually call into Random etc. here
        a=[-0.34354309486711065, -1.0995966004923408, -1.031706382670448, 0.3183044791424319, 0.67787316130825, 1.1324681536249555, 1.2939921062585586, -0.6582203791206142, 1.4695904633205077, 1.5427816212385765, 1.4823524032258817, 0.42815319406559155, -0.4578923008551234, 0.9541115645590403, -1.1768032568149391, 0.09746177747481431, 0.5676618046059924, -0.07301172550842665, 0.2133270257363731, 0.6249497564601051, 0.030033374314663457, 0.9989897307774964, -0.14633638359521245, -0.13984783088967517, -0.07318127088482887, -0.8827464255133538, -0.1551292742796804, -0.5626619648286509, 1.195609759941277, 0.18044593019778774, 0.9906068677115775, 1.067415336363193, -0.09019199880824731, -0.0733557563698599, 1.2365757473020829, 0.6421378506716701, 0.911971133386629, -0.6604354172921325, 1.248280591046975, 2.086058112053022, -1.1209441193889569, -1.8264659931287404, -0.02394457072094552, -0.31598589415658596, 0.14129402137020985, -1.47055974020114, -0.5647486968155041, 0.6213177557341366, 1.47339588963977, 0.5718280587675062, 1.0992536620777364, -0.31467898547034223, -0.33036645614726445, 1.2610107709091767, 0.041089383886570026, -0.8468181989917779, -0.22891621657661404, -0.9619057469455553, -0.31564076522391055, 1.5426666354392973, 0.37072922620724014, -1.294821169478836, -0.3750959408197882, 0.15235550226977407, -1.1352802216110054, -1.4474576663572862, 1.9765748857275764, -1.691136450322534, 0.22417169521718713, -1.014501941287588, 0.9819618489485618, -1.0309264365918522, -0.46725203203010973, -1.9280180251605148, -0.5775542280478414, 3.305450570359804, 0.17791649755099412, -1.3493878073525758, 1.7952206907296888, 0.10818984149605794, -0.8436885213045058, -0.009094522169231267, -1.9067584282323635, -0.4555136343244378, 0.7041913638409038, -0.08615324254645132, 0.07379284355120926, 0.5436464877324115, 0.06375117639292655, -0.42987929424629967, -0.43876721563140775, -1.2559740614842871, -1.0434458219115856, -0.5415017141491355, 0.5924642659992275, 1.54568956318039, 0.8633157674590743, 1.1005805635355026, -1.910737345963861, -0.4742674166832837],
        b=[-0.8350547364341157, -0.038903436082298126, -0.7428209115538095, -1.4702332997988619, 0.2929901876823982, 1.480656821045197, -0.7496016270089672, -1.1816175524449404, -0.8929201507386697, -0.4513027458407115, -0.03467987003478814, -0.01703216323285711, 2.269208613937625, -1.122760313412779, -1.690293811059567, 0.35637058611995015, -0.5492956660472131, 0.46065703485294224, 0.4437979543972946, 0.28240840472432244, 0.690877660142549, -2.5626640462814136, 0.05775480227672292, 0.3471312190888867, 1.724863523389576, -0.30223523085282833, -0.9081864727632714, -0.9755930057667722, -0.8633376120374543, -0.6320827659443491, -0.8996197573701549, 1.3098637982582648, 0.7259306350309777, -0.6677231848170275, -0.24152809622940857, 2.1413209082677906, -1.6229571597346615, 1.6318320479372053, 0.5061999438250513, 1.8722835557539328, -0.28755361383607164, -0.39835043144482646, -1.9191542821529093, 0.1861362910513889, -1.7370796754676385, -0.5847017666989085, -0.6139627808148969, -0.5828743912421838, 0.23866575269053403, 1.1395769333095256, 0.03673066354212003, -1.0246047274123449, 0.81119369428263, -0.2413679376829325, -0.16850699998847837, 0.7193564163546119, -1.0250120470351711, -0.020112597427054398, 1.4023645771518407, -1.2964559002213754, 0.004640153954934036, -1.5456922587361066, -1.1892087658060522, -0.5803343106096389, 1.3773763927487954, -1.5428894968829066, -0.6571326425215163, -0.16942661520407568, 0.3902986077040804, -0.5102558720576744, -1.7157849780094623, 1.6557540726543791, 1.5039386944282804, 0.041349457163033926, 1.726208631975933, 1.5872756183910883, 0.3571235862890753, 0.03145711944329936, -1.0810465561583815, 0.2542573690863064, -0.8061299707651735, 0.6202116497962467, -0.5558158303191691, -0.9388942510860714, 0.850513949232004, -0.4858445604340498, 0.7199256833112352, -0.48438425564853616, 0.0201633201948252, 1.01586069947111, -1.2132268468503575, -0.2566512612879169, -0.08918635759129184, -0.36100301648947447, 0.026391614522651263, 0.7647120517033543, 1.2084488286459771, -0.19298755667218181, 0.1995911553994999, 0.025362662538195947]
    )
    
    @test pairplot(table) isa Figure
    @test pairplot((;table.a)) isa Figure
    @test pairplot(
        table => (PairPlots.Hist(), )
    ) isa Figure
    @test pairplot(
        table => (PairPlots.Hist(), PairPlots.MarginHist())
    ) isa Figure
    @test pairplot(hcat(table.a, table.b)) isa Figure
    @test pairplot(
        table => (PairPlots.Hist(), PairPlots.TrendLine())
    ) isa Figure
    @test pairplot(
        table => (PairPlots.Hist(), PairPlots.PearsonCorrelation())
    ) isa Figure
    @test pairplot(
        table => (PairPlots.Hist(),),
        PairPlots.Truth((; a = 0.0, b = 0.0))
    ) isa Figure

    ctable = CustomTable(table)
    @test pairplot(ctable) isa Figure
    @test pairplot(
        ctable => (PairPlots.Hist(),)
    ) isa Figure
    @test pairplot(
        ctable => (PairPlots.Hist(), PairPlots.MarginHist())
    ) isa Figure
end

@testset "Diagonal panels have no y decorations" begin

    # The vertical axis of a diagonal panel is a marginal density scale rather than
    # the parameter itself, so it should carry no ticks or label -- in either corner.
    table = (;
        a = [-0.34, -1.09, -1.03, 0.31, 0.67, 1.13, 1.29, -0.65, 1.46, 1.54],
        b = [-0.83, -0.03, -0.74, -1.47, 0.29, 1.48, -0.74, -1.18, -0.89, -0.45],
        c = [ 0.52, -1.31,  0.07,  0.94, 1.72, 0.11, -1.62,  0.38, 1.40, -0.29],
    )
    layers = (PairPlots.Hist(), PairPlots.MarginHist())

    # Collect (row, col, yticksvisible, yticklabelsvisible, ylabelvisible) for the
    # panels on the diagonal of a pairplot drawn into its own GridLayout.
    function diagonal_y_decorations(; bottomleft, topright)
        fig = Figure()
        grid = GridLayout(fig[1,1])
        pairplot(grid, PairPlots.Series(table; bottomleft, topright) => layers)
        decorations = Tuple{Int,Int,Bool,Bool,Bool}[]
        for content in grid.content
            ax = content.content
            ax isa Makie.Axis || continue
            row = first(content.span.rows)
            col = first(content.span.cols)
            row == col || continue
            push!(decorations, (row, col, ax.yticksvisible[], ax.yticklabelsvisible[], ax.ylabelvisible[]))
        end
        return sort!(decorations)
    end

    bottomleft_diag = diagonal_y_decorations(bottomleft=true, topright=false)
    topright_diag = diagonal_y_decorations(bottomleft=false, topright=true)

    @test length(bottomleft_diag) == 3
    @test length(topright_diag) == 3
    # No diagonal panel in either corner shows y ticks, tick labels, or a y label.
    @test all(d -> !any(d[3:5]), bottomleft_diag)
    @test all(d -> !any(d[3:5]), topright_diag)
    # ...and so the two corners agree panel-for-panel (issue #87: the last diagonal
    # panel of a topright plot kept its density scale).
    @test bottomleft_diag == topright_diag
end

@testset "Every viz layer accepts the multi-series stroke defaults" begin

    # With more than one series, SeriesDefaults injects `strokecolor` into the
    # series kwargs so the layers can be told apart. Layers whose underlying Makie
    # recipe has no stroke attributes must strip it in `remove_attrs`, or plotting
    # throws "Invalid attribute strokecolor" -- issue #65 (Hist -> heatmap) and
    # issue #66 (MarginStepHist -> stairs).
    t1 = (;
        a = [-0.34, -1.09, -1.03, 0.31, 0.67, 1.13, 1.29, -0.65, 1.46, 1.54],
        b = [-0.83, -0.03, -0.74, -1.47, 0.29, 1.48, -0.74, -1.18, -0.89, -0.45],
    )
    t2 = (;
        a = [ 0.52, -1.31, 0.07, 0.94, 1.72, 0.11, -1.62, 0.38, 1.40, -0.29],
        b = [ 1.02, 0.44, -0.16, -0.91, 0.23, -1.35, 0.78, 1.19, -0.52, 0.61],
    )

    body_layers = (
        PairPlots.HexBin(), PairPlots.Hist(), PairPlots.Contour(),
        PairPlots.Contourf(), PairPlots.Scatter(), PairPlots.TrendLine(),
    )
    diag_layers = (
        PairPlots.MarginQuantileText(), PairPlots.MarginQuantileLines(),
        PairPlots.MarginHist(), PairPlots.MarginStepHist(), PairPlots.MarginDensity(),
    )

    for viz in (body_layers..., diag_layers...)
        @test pairplot(t1 => (viz,), t2 => (viz,)) isa Figure
    end

    # The same attributes set explicitly on the series, with several layers stacked,
    # which is how issue #66 was actually hit.
    @test pairplot(
        PairPlots.Series(t1, color=:red, strokecolor=:red, strokewidth=2) =>
            (PairPlots.Hist(), PairPlots.MarginStepHist()),
        PairPlots.Series(t2, color=:blue, strokecolor=:blue, strokewidth=2) =>
            (PairPlots.Hist(), PairPlots.MarginStepHist()),
    ) isa Figure

    # Single-series plots take a different defaults path and must keep working.
    for viz in (body_layers..., diag_layers...)
        @test pairplot(t1 => (viz,)) isa Figure
    end
end

@testset "An already-constructed series on the left of a Pair" begin

    # `pairplot(grid, ::Pair{<:AbstractSeries}...)` is more specific than the
    # generic `pairplot(grid, ::Any...)` that assigns defaults, so a call whose
    # arguments are *all* Pairs skips the defaults layer entirely and always
    # worked. As soon as one argument is not a Pair, the generic method runs and
    # its Pair branches re-wrap the left-hand side in `Series(...)` -- which
    # throws if it is already a Series/Truth/Band. Issue #80.
    t1 = (;
        a = [-0.34, -1.09, -1.03, 0.31, 0.67, 1.13, 1.29, -0.65, 1.46, 1.54],
        b = [-0.83, -0.03, -0.74, -1.47, 0.29, 1.48, -0.74, -1.18, -0.89, -0.45],
    )
    t2 = (;
        a = [ 0.52, -1.31, 0.07, 0.94, 1.72, 0.11, -1.62, 0.38, 1.40, -0.29],
        b = [ 1.02, 0.44, -0.16, -0.91, 0.23, -1.35, 0.78, 1.19, -0.52, 0.61],
    )
    truth = PairPlots.Truth((; a = 0.0, b = 0.0))
    band = PairPlots.Band((; a = [-1.0, 1.0], b = [-1.0, 1.0]))

    # A Truth/Band does not count towards the series total, so these stay on the
    # single-series branch even though they carry two arguments.
    @test pairplot(PairPlots.Series(t1) => (PairPlots.Scatter(),), truth) isa Figure
    @test pairplot(PairPlots.Series(t1) => (PairPlots.Scatter(),), band) isa Figure

    # A Truth/Band on the left of a Pair, on each of the three defaults branches.
    @test pairplot(t1, truth => (PairPlots.MarginLines(),)) isa Figure
    @test pairplot(t1, t2, truth => (PairPlots.MarginLines(),)) isa Figure
    @test pairplot(t1, band => (PairPlots.MarginBands(alpha=0.4),)) isa Figure
    @test pairplot(t1, t2, band => (PairPlots.MarginBands(alpha=0.4),)) isa Figure

    # More than five series is a third branch again.
    @test pairplot(t1, t1, t1, t1, t1,
                   PairPlots.Series(t2) => (PairPlots.Scatter(),),
                   truth => (PairPlots.MarginLines(),)) isa Figure

    # Multi-series with a bare Series alongside a Series pair: the case #78 fixed.
    @test pairplot(PairPlots.Series(t1), PairPlots.Series(t2) => (PairPlots.Scatter(),)) isa Figure

    # All-Pairs calls reach the specific method directly and must stay working.
    @test pairplot(PairPlots.Series(t1) => (PairPlots.Scatter(),)) isa Figure
    @test pairplot(
        PairPlots.Series(t1) => (PairPlots.Scatter(),),
        truth => (PairPlots.MarginLines(),),
        band => (PairPlots.MarginBands(alpha=0.4),),
    ) isa Figure
end

@testset "Ring contours pick the enclosing curve regardless of winding" begin

    # `process_ring_contours` turns a level's disconnected curves into filled
    # polygons with holes. Contours.jl does not orient those curves consistently,
    # so the enclosing curve has to be found by *unsigned* area -- ranking the
    # signed shoelace value selects the hole whenever the outer ring happens to
    # wind the other way, and the annulus is then drawn as a filled disc with the
    # fill in the wrong place entirely. Issue #91.

    CL = PairPlots.ContourLib

    # A closed circle of `n` segments, `ccw=false` giving the opposite winding.
    function ring(r; n=64, ccw=true)
        ts = range(0, 2pi, length=n+1)          # closes: last point == first
        ccw || (ts = reverse(ts))
        CL.Curve2([(r*cos(t), r*sin(t)) for t in ts])
    end

    # An annulus, in all four combinations of the two curves' windings.
    for outer_ccw in (true, false), inner_ccw in (true, false)
        level = CL.ContourLevel(1.0, [ring(1.0; ccw=inner_ccw), ring(3.0; ccw=outer_ccw)])
        polys = PairPlots.process_ring_contours(level)

        @test length(polys) == 1
        p = only(polys)

        # The exterior must be the r=3 ring, and the r=1 ring must become a hole.
        radii = [hypot(q[1], q[2]) for q in Makie.GeometryBasics.coordinates(p.exterior)]
        @test all(≈(3.0; atol=1e-5), radii)
        @test length(p.interiors) == 1
        hole_radii = [hypot(q[1], q[2]) for q in only(p.interiors)]
        @test all(≈(1.0; atol=1e-5), hole_radii)
    end

    # A lone curve is its own exterior and has no hole, either way round.
    for ccw in (true, false)
        polys = PairPlots.process_ring_contours(CL.ContourLevel(1.0, [ring(2.0; ccw)]))
        @test length(polys) == 1
        @test isempty(only(polys).interiors)
    end

    # The unsigned area is what ranks them; the signed one flips with the winding.
    sq = Makie.Point2f[(0,0), (1,0), (1,1), (0,1), (0,0)]
    @test PairPlots.polygon_area(sq) ≈ 1.0
    @test PairPlots.polygon_area(reverse(sq)) ≈ -1.0
end
