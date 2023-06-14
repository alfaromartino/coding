merged_df2 = merged_df[.!(occursin.(r"Antarct", merged_df.short_name_country)),:]

R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df2), 
                                  aes(x=long, y = lat, group = group, 
                                      fill=share_income),
                                  color = "white", linewidth=0.05)
                                  
#we get rid of background, grid, and latitude/longitude
our_gg <- our_gg + user_theme()

#changing aspect ratio
our_gg <- our_gg + coord_fixed(1.3) 

#to change color scale (see color codes here https://derekogle.com/NCGraphing/resources/colors)
our_gg <- our_gg + scale_fill_gradient(low="lightskyblue", high="steelblue4", name = "Income Share")

#additional options for the legend of color scale 
our_gg <- our_gg + theme(
                         legend.position = "bottom",
                         legend.key.height = unit(0.5, "cm"),
                         legend.key.width = unit(2, "cm"))

#saving the graph
height <- 5
ggsave(filename = file.path($(graphs_folder),"file_graph01.svg"), plot = our_gg, width = height * 3, height = height)
"""