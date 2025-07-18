"""
    pdf_plot(hists::Vector{Union{Hist1D, Hist2D}}, x_axis_labels::Vector{String}, Titles::Vector{String}; y_axis_labels=nothing, normalize_hists=true, ofile="kinematic_histograms.pdf")
    Loops throug the histograms in hists and plots them in a PDF with name `ofile`. If normalize_hist is set then the histogras are normalized.
"""
function pdf_plot(hists, x_axis_labels, Titles; y_axis_labels=nothing, normalize_hists=true, ofile="kinematic_histograms.pdf")
    
    #Check if we have the required number of labels and Titles

    if length(hists) != length(Titles)
        println("Number of histograms and titles do not match")
        return
    end

    if length(hists) != length(x_axis_labels)
        println("Number of histograms and x_axis_labels do not match")
        return
    end

    if y_axis_labels !== nothing
        if count(x -> x isa Hist2D, hists) != length(y_axis_labels)
            println("Number of 2D histograms and y_axis_labels do not match")
            return
        end
    end

    if isfile(ofile)
        rm(ofile)
    end

    CairoMakie.activate!(type = "pdf")
    index_2d_label = 1

    for (i, hist) in enumerate(hists)

        if normalize_hists
            hist_norm = normalize(hist)
        else
            hist_norm = hist
        end

        if(typeof(hist) == Hist1D{Float64})

            fig = CairoMakie.Figure()

            if normalize_hists
                ax = CairoMakie.Axis(fig[1,1], xlabel=x_axis_labels[i], ylabel="Normalized Counts", title=Titles[i])
            else
                ax = CairoMakie.Axis(fig[1,1], xlabel=x_axis_labels[i], ylabel="Counts", title=Titles[i])
            end

            CairoMakie.stephist!(ax, hist_norm)
            CairoMakie.errorbars!(ax, hist_norm; whiskerwidth=6)
            statbox!(fig, hist)
            CairoMakie.save("temp.pdf", fig)
            append_pdf!(ofile, "temp.pdf", cleanup=true)    

        else
            fig = CairoMakie.Figure()
            axis_heatmap, heatmap = CairoMakie.heatmap(fig[1,1], hist_norm, axis=(title=Titles[i], xlabel=x_axis_labels[i], ylabel=y_axis_labels[index_2d_label], ))
            if normalize_hists
                CairoMakie.Colorbar(fig[1,2], heatmap, label="Normalized Counts")
            else
                CairoMakie.Colorbar(fig[1,2], heatmap, label="Normalized Counts")
            end

            index_2d_label += 1
            statbox!(fig, hist; position=(1,3))
            CairoMakie.save("temp.pdf", fig)
            append_pdf!(ofile, "temp.pdf", cleanup=true)    
        end
    end

    

    return
end

function plot_hist(hist, title, xlabel, ylabel; label=nothing, normalize_hist=false, xscale=identity, yscale=identity, colorbar_label="", colorscale=identity, limits=(nothing, nothing), ATLAS_label=nothing, ATLAS_label_offset=(30, -20))

    CairoMakie.activate!(type = "png")
    fig = CairoMakie.Figure()

    if normalize_hist
        hist_norm = normalize(hist)
    else
        hist_norm = hist
    end

    if typeof(hist) == Hist1D{Float64}
        ax = CairoMakie.Axis(fig[1,1]; xlabel, ylabel, title, yscale, limits)
        CairoMakie.stephist!(ax, hist_norm; label)
        CairoMakie.errorbars!(ax, hist_norm; whiskerwidth=6)
            
    elseif typeof(hist) == Hist2D{Float64}
        ax, heatmap = CairoMakie.heatmap(fig[1,1], hist_norm, axis=(;title, xlabel, ylabel, xscale, yscale); colorscale)
        CairoMakie.Colorbar(fig[1,2], heatmap; label=colorbar_label, scale=log10)
    end

    if label !== nothing
        CairoMakie.axislegend()
    end

    if ATLAS_label !== nothing
        add_ATLAS_internal!(ax, ATLAS_label; offset=ATLAS_label_offset)
    end

    current_figure()
end


function plot_comparison(hist1, hist2, title, xlabel, ylabel, hist1_label, hist2_label, comp_label; normalize_hists=true, yscale=identity, plot_as_data=[false, false], limits=(nothing, nothing), ATLAS_label=nothing, ATLAS_label_offset=(30, -20))

    #Plot the histograms
    
    CairoMakie.activate!(type = "png")
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1]; xlabel, ylabel, title, yscale, limits)

    if normalize_hists
        hist1_norm = normalize(hist1)
        hist2_norm = normalize(hist2)
    else
        hist1_norm = hist1
        hist2_norm = hist2
    end

    CairoMakie.errorbars!(ax, hist1_norm; whiskerwidth=6, color=CairoMakie.Makie.wong_colors()[2])

    if plot_as_data[1]
        CairoMakie.scatter!(ax, hist1_norm; label=hist1_label, color=CairoMakie.Makie.wong_colors()[2])
    else
       CairoMakie.stephist!(ax, hist1_norm; label=hist1_label, color=CairoMakie.Makie.wong_colors()[2])
    end
    
    CairoMakie.errorbars!(ax, hist2_norm; whiskerwidth=6, color=CairoMakie.Makie.wong_colors()[1])
    
    if plot_as_data[2]
        CairoMakie.scatter!(ax, hist2_norm; label=hist2_label, color=CairoMakie.Makie.wong_colors()[1])
    else
        CairoMakie.stephist!(ax, hist2_norm, label=hist2_label, color=CairoMakie.Makie.wong_colors()[1])
    end

    CairoMakie.axislegend()

    ratioax = CairoMakie.Axis(fig[2, 1]; xlabel, ylabel=comp_label, tellwidth=true)
    FHist.ratiohist!(ratioax, hist2_norm/hist1_norm; color=CairoMakie.Makie.wong_colors()[2])
    CairoMakie.ylims!(0.5, 1.5)
    CairoMakie.linkxaxes!(ratioax, ax)
    CairoMakie.hidexdecorations!(ax; minorticks=false, ticks=false)
    CairoMakie.rowsize!(fig.layout, 2, CairoMakie.Makie.Relative(1/6))

    if ATLAS_label !== nothing
        add_ATLAS_internal!(ax, ATLAS_label; offset=ATLAS_label_offset)
    end

    CairoMakie.current_figure()

end

function multi_plot(hists, title, xlabel, ylabel, hist_labels; data_hist=nothing, data_hist_style="scatter", data_label="Data", yscale=identity, normalize_hists="", stack=false, limits=(nothing, nothing), plot_ratio=false, ratio_label="Data/MC", ATLAS_label=nothing, ATLAS_label_offset=(30, -20))

    CairoMakie.activate!(type = "png")
    fig = CairoMakie.Figure()
    ax = CairoMakie.Axis(fig[1,1]; xlabel, ylabel, title, yscale, limits)

    if normalize_hists == "individual"
        norm_hists = [normalize(hist) for hist in hists]
    elseif normalize_hists == "total"
        tot_integral = sum(integral(hist) for hist in hists)
        norm_hists = [hist * (1/tot_integral) for hist in hists]
    else
        norm_hists = hists
    end

    if stack
        stackedhist!(ax, norm_hists, color=gaudi_colors, errorcolor=(:white, 0.0))
        elements = [PolyElement(polycolor = gaudi_colors[i]) for i in 1:length(hist_labels)]
    else

        for (i, hist) in enumerate(norm_hists)
            CairoMakie.stephist!(ax, hist; clamp_bincounts=true)
            CairoMakie.errorbars!(ax, hist; whiskerwidth=6, clamp_errors=true)
        end
        elements = [LineElement(linecolor = CairoMakie.Makie.wong_colors()[i]) for i in 1:length(hist_labels)]
    end

    if data_hist !== nothing
        if normalize_hists == "individual" || normalize_hists == "total"
            data_hist_norm = normalize(data_hist)
        else
            data_hist_norm = data_hist
        end

        if data_hist_style == "scatter"
            CairoMakie.scatter!(ax, data_hist_norm; color=:black)
            elements = vcat(elements, MarkerElement(marker = :circle, markercolor = :black))
        elseif data_hist_style == "stephist"
            CairoMakie.stephist!(ax, data_hist_norm; label=data_label, color=:black)
            elements = vcat(elements, LineElement(linecolor = :black))
        end
        push!(hist_labels, data_label)

        if plot_ratio
            CairoMakie.errorbars!(ax, data_hist; whiskerwidth=6, clamp_errors=true, color=:black)
            ratioax = CairoMakie.Axis(fig[2, 1]; xlabel, ylabel=ratio_label, tellwidth=true)
            FHist.ratiohist!(ratioax, data_hist_norm/sum(norm_hists); color=CairoMakie.Makie.wong_colors()[2])
            CairoMakie.ylims!(0.5, 1.5)
            CairoMakie.linkxaxes!(ratioax, ax)
            CairoMakie.hidexdecorations!(ax; minorticks=false, ticks=false)
            CairoMakie.rowsize!(fig.layout, 2, CairoMakie.Makie.Relative(1/6))
        end
    end

    Legend(fig[1,2], elements, hist_labels, "Legend")

    if ATLAS_label !== nothing
        add_ATLAS_internal!(ax, ATLAS_label; offset=ATLAS_label_offset)
    end

    CairoMakie.current_figure()
end
