R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#we get rid of background, grid, and latitude/longitude
our_gg <- our_gg + user_theme()

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01b.svg"), plot = our_gg)
"""