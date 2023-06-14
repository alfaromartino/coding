#= PACKAGES THAT WE USE IN CONFIG.MD
   (THEY CAN'T BE LOADED FROM UTILS.JL 
    WHILE MAKE THEM AVAILABLE IN CONFIG.MD) 
   
   USED FOR ALL THE FUNCTIONS WE INCLUDE IN CONFIG.MD=#

using DataFrames, CSV, OrderedCollections, Tables



# basic functions
remove_md(x) = replace(x, r".md$" => "")


#include(joinpath("C:/", "DATA", "blog", "initial_folders.jl"))
#include(joinpath("C:/", "DATA", "blog", "split_code.jl"))

