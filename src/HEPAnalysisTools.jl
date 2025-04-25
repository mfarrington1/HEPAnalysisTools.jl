module HEPAnalysisTools
using Makie, CairoMakie
using ColorSchemes
using FHist
using JSON

include("./PlottingTools.jl")
export pdf_plot, plot_hist, plot_comparison, multi_plot
end