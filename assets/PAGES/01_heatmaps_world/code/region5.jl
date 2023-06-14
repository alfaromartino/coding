@rput merged_df     # we send our merged dataframe to R

# we create the graph using RCall
R"""
#baseline code
our_gg <- ggplot() + geom_polygon(data = merged_df, 
                                  aes(x=long, y = lat, group = group, 
                                      fill=share_income)) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph0.svg"), plot = our_gg)
"""