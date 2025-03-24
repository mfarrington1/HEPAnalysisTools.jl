using Documenter
using DocumenterVitepress
using HEPAnalysisTools

repopath = if haskey(ENV, "GITHUB_ACTION")
    "github.com/mfarrington1/HEPAnalysisTools.jl"
else
    "gitlab.cern.ch/HEPAnalysisTools-jl"
end

deploy_url = if haskey(ENV, "GITHUB_ACTION")
    nothing
else
    "HEPAnalysisTools-jl.docs.cern.ch"
end

makedocs(;
         modules=[DarkQCD],
         format=DocumenterVitepress.MarkdownVitepress(; repo = repopath, devbranch = "main", devurl = "dev", deploy_url),
         # format = Documenter.HTML(
         #                          prettyurls = get(ENV, "CI", nothing) == "true",
         #                          assets=String[],
         #                         ),
         pages=[
                "Introduction" => "index.md",
                "Internal APIs" => "internalapis.md",
               ],
         repo="https://$repopath/blob/{commit}{path}#L{line}",
         sitename="HEPAnalysisTools.jl",
         authors="Michael Farrington",
        )

        
deploydocs(;
           repo=repopath,
           branch = "gh-pages",
          )
