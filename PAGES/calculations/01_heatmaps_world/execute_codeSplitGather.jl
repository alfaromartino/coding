
###################
#       BASICS
###################
# only used in case I didn't load it when I ran `serve()` for Franklin
include(joinpath("C:/", "JULIA_UTILS", "initial_folders.jl"))
include(joinpath("C:/", "JULIA_UTILS", "code_split_gather.jl"))



#######################################################################################################################
#                                                   WHICH WE NEED TO DEFINE!!!!
########################################################################################################################

#name of PAGE in Franklin 
page_folder = "01_heatmaps_world"


#location of julia file
filejl      = "$(folderCoding.calculations)\\$(page_folder)\\world_map.jl"



#######################################################################################################################
#
########################################################################################################################

###################
#       CREATE FOLDERS (if they don't already exist)
###################

function create_folder(x) 
    isdir(x) || (mkdir(x))
    x
end

asset_folder    = create_folder("$(folderCoding.assets)\\$(page_folder)")
code_folder     = create_folder("$(asset_folder)\\code")
graphs_folder   = create_folder("$(asset_folder)\\graphs")




###################
#       SPLIT AND GATHER CHODE
###################
# this splits and gathers, and then returns a vector with each chunk of code
code_names, code_content = splitAndGatherCode(code_folder, filejl)


###################
#       STORE RESULTS
###################
store_outputs(code_folder, code_names)







############################################################################
#
#      CREATE PACKAGE ENVIRONMENT FOR THE FIRST TIME
#
############################################################################
#=
# execute this to create the package environment
import Pkg

# packages needed
list_packages  = ["DataFrames", "RCall", "CSV", "Downloads", "LazyArrays"]

packages_folder = "$(asset_folder)\\codeDownload"
Pkg.generate("$(packages_folder)")
Pkg.activate("$(packages_folder)")
Pkg.add(list_packages)

rm("$(packages_folder)\\src", recursive=true)
=#


packages_folder = "$(asset_folder)\\codeDownload"
text_to_add = """
#= This code allows you to reproduce the code with the same version of packages used
    at the moment of writing the note. 
   Put all files (allCode_withPkg.jl, Manifest.toml, and Project.toml) in C:/code_downloaded. 
    Otherwise, it won't work. =#

Pkg.activate(joinpath("C:/", "code_downloaded"))
Pkg.instantiate() #to install the specific version of packages used in this project
"""
add_packageList(code_folder, packages_folder, text_to_add)

add_packageList(code_folder, packages_folder, ""; file_created="allCode")


