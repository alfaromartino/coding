# all information summarized in dftoc


############################################################################
#
#               FOLDER CONTAINING .MD FILES
#
############################################################################


path_prepath = "coding"
subfolder    = "PAGES"


############################################################################
#
#                           BASIC INFORMATION
#
############################################################################

using DataFrames

function previous_folder(path; nr_prev=1) 
    aux = ntuple(x -> "..", nr_prev)
    abspath(joinpath("$(path)", aux...))
 end

function capture_PAGEdescription(folder, file, name)
    file       = open("$folder\\$file", "r")
    content    = read(file, String)
    expression = Regex("$(name)\\s*=\\s*\"(?<group>.*)\"")
    xx         = match(expression, content)
    return string.(xx[:group])
end

function create_dftoc(subfolder)
    folder = joinpath(previous_folder(@__DIR__), "$(subfolder)")

    files   = readdir(folder)  |>  x -> x[startswith.(x, r"^\d")]    #we keep those files that start with a number
    titles  = capture_PAGEdescription.(folder, files,"PAGEpost_name")
    dates   = capture_PAGEdescription.(folder, files,"PAGEpost_date")
    updates = capture_PAGEdescription.(folder, files,"PAGEpost_update")

    page_names = replace.(files, r".md$" => "") #we remove .md
    pagemd     = string.(["$(subfolder)\\"], files)
    pagelink   = string.(["$(subfolder)\\"], page_names)


    chapter_nr  = eachindex(page_names)
    dftoc       = DataFrame(number=chapter_nr, name = files, pagemd = pagemd, pagelink = pagelink, 
                            title=titles, date=dates, update=updates)

    return dftoc
end

dftoc = create_dftoc(subfolder)




############################################################################
#
#                           TO CREATE THE NEXT AND PREVIOUS PAGE
#
############################################################################

function add_nextAndPrevious!(dftoc)
    next_page = [dftoc[i+1, :pagemd] for i in 1:nrow(dftoc)-1]
    push!(next_page,"")
    
    prev_page = [vcat(dftoc.pagemd...)[i-1] for i in 2:nrow(dftoc)]
    pushfirst!(prev_page,"")

    dftoc.next_page = replace.(next_page, r".md$" .=> "")
    dftoc.prev_page = replace.(prev_page, r".md$" .=> "")
end

add_nextAndPrevious!(dftoc)

dftoc[lastindex(dftoc.pagemd), :next_page] = replace(dftoc.pagemd[1], r".md$" => "")
dftoc[firstindex(dftoc.pagemd), :prev_page] = replace(dftoc.pagemd[end], r".md$" => "")


############################################################################
#
#                           TO CREATE ASSETS LOCATION
#
############################################################################

# TO REFER TO ASSETS (for images and the link to codeDownload)
assets_folder(PAGEfile) = "/assets/$(subfolder)/$(PAGEfile)"
dftoc.path_assets       = replace.(dftoc.name, r".md$" => "") |> #we remove .md 
                          x -> assets_folder.(x)

let dftoc = dftoc
    assets_folder(PAGEfile) = "/assets/$(subfolder)/$(PAGEfile)"
    html_tree               = "https://github.com/alfaromartino/$(path_prepath)/tree/main/"
    dftoc.path_codeDownload = string.(html_tree, dftoc.path_assets, "/codeDownload")
end

