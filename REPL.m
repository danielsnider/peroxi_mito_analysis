while true
    try
        clear plot_scatter_pero_intensity_vs_dist
        plot_scatter_pero_intensity_vs_dist
        pause(.3)
    catch ME
        getReport(ME)
        pause(1)
    end

end