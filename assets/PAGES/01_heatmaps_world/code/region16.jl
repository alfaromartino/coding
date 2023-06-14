R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#saving the graph
height <- 5
ggsave(filename = file.path($(graphs_folder),"file_graph01f.svg"), plot = our_gg, width = height * 3, height = height)
"""