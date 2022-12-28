using Documenter, CairoMakie, PairPlots

ENV["DATAFRAMES_ROWS"] = 5

makedocs(
    sitename="PairPlots.jl",
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Guide" => "guide.md",
        "API" => "api.md",
    ],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets = ["assets/theme.css"],
    ),
)


deploydocs(
    repo = "github.com/sefffal/PairPlots.jl.git",
    devbranch = "master",
    push_preview = true
)
