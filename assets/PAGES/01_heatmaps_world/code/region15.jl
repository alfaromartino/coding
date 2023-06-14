R"""
#base code + borders
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income),
                                  color = "white", linewidth=0.1) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01e.svg"), plot = our_gg)
"""