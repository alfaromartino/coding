R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#changing aspect ratio
our_gg <- our_gg + coord_fixed(1.3) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01c.svg"), plot = our_gg)
"""