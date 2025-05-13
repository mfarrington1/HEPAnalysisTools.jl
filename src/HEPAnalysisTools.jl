module HEPAnalysisTools
using Makie, CairoMakie
using ColorSchemes
using FHist
using JSON
using LorentzVectorHEP

include("./PlottingTools.jl")
export pdf_plot, plot_hist, plot_comparison, multi_plot

include("./PlottingObjects.jl")
export gaudi_colors, AtlasTheme, set_ATLAS_theme, add_ATLAS_internal!

include("./EventDisplay.jl")
export event_display

end