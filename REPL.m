while true
    try
        clear plot_bar_stacked_num_contacts
        plot_bar_stacked_num_contacts
        pause(.3)
    catch ME
        getReport(ME)
        pause(1)
    end

end