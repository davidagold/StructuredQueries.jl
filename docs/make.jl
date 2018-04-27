using Documenter, StructuredQueries

makedocs(
    modules = [StructuredQueries],
    format = :html,
    sitename = "StructuredQueries.jl",
    authors = "David A. Gold and contributors.",
    pages = Any[
        "Home" => "index.md",
        "Manual" => Any[
            "Guide" => "man/guide.md",
            # "Syntax" => "man/syntax.md",
            # "Extension" => "man/extension.md",
            "Examples" => "man/examples.md"
        ],
        "Library" => Any[
            "Public" => "lib/public.md"
            "Internals" => Any[
                "Internals" => "lib/internals.md",
                "lib/internals/query.md",
                "lib/internals/graph.md",
                "lib/internals/node.md",
                "lib/internals/helper.md",
                "lib/internals/expr.md",
                "lib/internals/collect.md"
            ]
        ]
    ]
)

deploydocs(
    julia = "nightly",
    repo = "github.com/davidagold/StructuredQueries.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
