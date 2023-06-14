using DataFrames, RCall, CSV, Downloads

R"""
library(ggplot2)
library(svglite) #to save graphs in svg format, otherwise not necessary
""" 
 
 ############################################################################
#
#                           FAKE DATA
#
############################################################################ 
 
 using Random
link = Downloads.download("https://alfaromartino.github.io/data/countries_mapCoordinates.csv")
dft  = DataFrame(CSV.File(link)) |> x-> dropmissing(x, :iso3)

#we get rid of unidentified countries and missing data
dropmissing!(dft, :iso3)
dft = dft[occursin.(r"\w", dft.iso3), :]

#= we create some fake data for income, 
   and then modify the values of the 3 top countries by income to make it more realistic =#
Random.seed!(1233)

our_df               = unique(dft[:,[:iso3]])
our_df.income        = rand(nrow(our_df))
  temp                 = view(our_df, occursin.(r"USA|CHN|DEU",our_df.iso3),:)
  temp.income          = maximum(our_df.income) .+ temp.income .* 10
our_df.share_income  = our_df.income ./ sum(our_df.income) .* 100
our_df.iso3         .= String.(our_df.iso3)

#final dataset
our_df = our_df[:, [:iso3, :share_income]]
println(our_df[1:5, :]) #hide 
 
 # we merge our dataframe with the file having map coordinates
link           = Downloads.download("https://alfaromartino.github.io/data/countries_mapCoordinates.csv")
df_coordinates = DataFrame(CSV.File(link)) |> x-> dropmissing(x, :iso3)

merged_df = leftjoin(df_coordinates, our_df, on=:iso3)
println(merged_df[15_000:15_000:70_000, Not([:sovereignty, :subregion])]) #hide 
 
 isdir(joinpath("C:/", "maps")) || mkdir(joinpath("C:/", "maps")) #create 'maps' folder if it doesn't exist

graphs_folder = joinpath("C:/", "maps") 
 
 # we create the graph using RCall


R"""
#baseline code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, 
                                      fill=share_income)) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph0.svg"), plot = our_gg)
""" 
 
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
 
 ############################################################################
#
#                           WORLD MAP - POLISHING
#
############################################################################

##############################################################################################################  ###code comment8 (((
######################################
# 1a) GETTING RID OF ANTARCTICA
###################################### 
 
 merged_df2 = merged_df[.!(occursin.(r"Antarct", merged_df.short_name_country)),:]

R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df2), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01a.svg"), plot = our_gg)
""" 
 
 ##ONE COUNTRY
merged_df2 = merged_df[occursin.(r"Argentina", merged_df.short_name_country),:]

R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df2), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01a_one_country.svg"), plot = our_gg)
""" 
 
 ######################################
# 1b) GETTING RID OF LATITUDE AND LONGITUDE
###################################### 
 
 R"""
user_theme <- function(){
  theme(
    panel.background = element_blank(),
    panel.border     = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),

    axis.line    = element_blank(),
    axis.text.x  = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
      )
      } 
""" 
 
 R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#we get rid of background, grid, and latitude/longitude
our_gg <- our_gg + user_theme()

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01b.svg"), plot = our_gg)
""" 
 
 ######################################
# 1c) CHANGING ASPECT RATIO
###################################### 
 
 R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#changing aspect ratio
our_gg <- our_gg + coord_fixed(1.3) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01c.svg"), plot = our_gg)
""" 
 
 ######################################
# 1d) COLOR SCALE
###################################### 
 
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
 
 ######################################
# 1e) BORDERS LINE - COLOR
###################################### 
 
 R"""
#base code + borders
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income),
                                  color = "white", linewidth=0.1) 

#saving the graph
ggsave(filename = file.path($(graphs_folder),"file_graph01e.svg"), plot = our_gg)
""" 
 
 ######################################
# 1f) CROPPING GRAPH
###################################### 
 
 R"""
#base code
our_gg <- ggplot() + geom_polygon(data = $(merged_df), 
                                  aes(x=long, y = lat, group = group, fill=share_income))

#saving the graph
height <- 5
ggsave(filename = file.path($(graphs_folder),"file_graph01f.svg"), plot = our_gg, width = height * 3, height = height)
""" 
 
 R"""
user_theme <- function(){
  theme(
    panel.background = element_blank(),
    panel.border     = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),

    axis.line    = element_blank(),
    axis.text.x  = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
      )
      } 
""" 
 
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
 
 