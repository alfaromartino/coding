R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#to change color scale
# see colors in R here https://derekogle.com/NCGraphing/resources/colors
our_gg <- our_gg + scale_fill_gradient(low="lightskyblue", high="steelblue4", name = "Income Share") 

#additional options for the legend of color scale 
our_gg <- our_gg + theme(
                         legend.position = "bottom",
                         legend.key.height = unit(0.5, "cm"),
                         legend.key.width = unit(2, "cm"))

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01d.svg"), plot = our_gg)
"""