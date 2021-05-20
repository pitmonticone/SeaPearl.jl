using Documenter
using SeaPearl

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true",
    sidebar_sitename = true,
    assets = [joinpath("assets", "favicon.ico")]
)
makedocs(
    sitename = "SeaPearl.jl",
    doctest = VERSION >= v"1.4",
    format = format,
    modules = [SeaPearl],
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Constraint Programming solver" => [
            "Introduction" => "CP/introduction.md",
            "Variables" => "CP/variables.md",
            "Constraint" => "CP/constraints.md",
            "Trailer" => "CP/trailer.md",
            "Core" => "CP/core.md"
        ],
        "Reinforcement Learning heuristics" => [
            "Introduction" => "RL/introduction.md",
            "Agent" => "RL/agent.md",
            "Environment" => "RL/env.md",
            "Heuristics" => "RL/heuristics.md"
        ],
        "Building Models" => [
            "Basics" => "models/basics.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
