using Documenter, DocumenterVitepress, CairoMakie, PairPlots

CairoMakie.activate!(type = "svg")

ENV["DATAFRAMES_ROWS"] = 5

makedocs(
    sitename="PairPlots.jl",
    repo="http://github.com/sefffal/PairPlots.jl",
    pages=[
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Guide" => "guide.md",
        "MCMCChains" => "chains.md",
        "API" => "api.md",
    ],
    format=DocumenterVitepress.MarkdownVitepress(
        repo="http://github.com/sefffal/PairPlots.jl",
        devurl = "dev",
    ),
)


deploydocs(
    repo = "github.com/sefffal/PairPlots.jl.git",
    devbranch = "master",
    push_preview = true
)
