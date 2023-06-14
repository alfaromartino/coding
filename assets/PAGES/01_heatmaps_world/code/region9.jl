merged_df2 = merged_df[.!(occursin.(r"Antarct", merged_df.short_name_country)),:]

R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df2), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01a.svg"), plot = our_gg)
"""