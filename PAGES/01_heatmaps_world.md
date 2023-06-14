
+++
PAGEpost_name    = "Simple World Heatmaps in Julia"
PAGEpost_date    = "June 6, 2023"
PAGEpost_update  = ""
PAGEpost_comment = ""
title            = PAGEpost_name

hascode          = true

# DO NOT DELETE
sections   = Pair{String,String}[]

dftoc      = globvar(:dftoc)
local_page = locvar(:fd_rpath)

include("$(@__DIR__)\\julia_utils\\local_functions.jl")
prev_page         = get_prevpage(dftoc, local_page)
next_page         = get_nextpage(dftoc, local_page)
assets            = get_pathassets(dftoc, local_page)
path_codeDownload = get_pathcodeDownload(dftoc, local_page)

+++



<!-- =====================================================================================================
                                                        SECTION 
========================================================================================================== -->
\begin{section}{title= "Summary"}

@@itemNoSpace
* \textbf{Goal}: To plot world heatmaps in Julia to visually represent country statistics. The approach handles all computations in Julia through `DataFrames`, and then executes a single command in R from within Julia (through `RCall`). I also provide a cleaned dataset containing map coordinates, which is ready to be used and identifies countries by their ISO codes.

* \textbf{Relevance of the Note}: I was looking for a simple way to draw world heatmaps in Julia. While existing Julia packages such as GMT.jl offer more advanced functionalities, they may be overkill for simple uses. Furthermore, standard datasets for map coordinates in R usually require further cleaning before they're ready to be used. To address these issues, I provide a straightforward approach if you want to handle the data and computations through Julia's DataFrames.\\
@@


\\Representing each country's share of the world income (fake data), the \textbf{final outcome} would be as follows
\justimg{center}{90%}{auto}{ {{assets}}/graphs/file_graph01.svg }





@@itemNoSpace
* \textbf{Links to Download the Files of this Note}: 
    * [World map coordinates](https://alfaromartino.github.io/data/countries_mapCoordinates.csv)
    * The Julia code is [here]( {{path_codeDownload}}) under the name `allCode.jl`. If you wish to run the code with the same package versions used in this post, download instead `allCode_withPkg.jl` along with `Project.toml` and `Manifest.toml`.
@@



\end{section}

<!-- =====================================================================================================
                                                    SECTION
========================================================================================================== -->
\begin{section}{title= "<span style=text-transform:lowercase>1st</span> Step: Handling Our Data in Julia"}

\subtitle{The Packages}

The following script lists all the packages in Julia and R for plotting heatmaps. Keep in mind that any code written in Julia between `R"""` and `"""` is interpreted as R code, which is an application of the package `RCall`. \footnote{
    `RCall` occasionally fails to recognize R's path when it's added. If you find an error after running `Pkg.add("RCall")`, try specifying the path to R on your computer and then building the package. Each of these steps are applied on my computer by running `ENV["R_HOME"]="C:\\Program Files\\R\\R-4.3.0"` and `Pkg.build("RCall")`.} 

\codeblue{open}{Loading Packages}{\input{julia}{./code/region1}}

\subtitle{The (Fake) Data}
We illustrate the approach through a self-contained example. To implement this, we generate some mock data representing each country's share of global income. This is contained in a DataFrame called `our_df`. The code for creating the DataFrame is omitted, as the specifics of how the mock data were generated are unimportant for our purposes. What matters is that, after cleaning our data and computing statistics, `our_df` will have the following variables.

\JFoutput{open}{`our_df[1:5,:]`}{\output{./code/region2}}

Now, we proceed to plot a world heatmap that represents the variable `share_income`. 

\end{section}


<!-- =====================================================================================================
                                                    SECTION
========================================================================================================== -->
\begin{section}{title= "<span style=text-transform:lowercase>2nd</span> Step: Adding Map Coordinates to the Data"}

To plot each country's share of the world's income, we need map coordinates. The `ggplot2` package in R can provide this information by executing `map_data("world")`, which internally calls the `maps` package. However, this dataset demands further cleaning before it can be used for world maps.\footnote{
    For instance, the dataset doesn't include each country's ISO code by default. Adding this information requires performing a matching using regular expressions, but the method is not guaranteed to work, as the documentation indicates.}  
Building on these data, I provide a cleaned dataset for map coordinates at this [link](https://alfaromartino.github.io/data/countries_mapCoordinates.csv). The dataset also includes some variables that identify zones, enabling you to restrict the plot to specific regions. 

The dataset with map coordinates can be merged with our DataFrame by running the snippet code below. This creates a new variable called `merged_df`, which is the DataFrame we'll use to plot the heatmap.
 
\bluewrapper{open}{Merging Datasets}{
\Fcode{\input{julia}{./code/region3}}
\out{\JFout{`merged_df`}{\output{./code/region3}}}
}

Specifically, the map coordinates are represented through four variables: `long`, `lat`, `group`, and `order`. These variables and `iso3`  are all we need to identify and draw a world map. Additionally, `share_income` represents our statistic of interest.

\end{section}

<!-- =====================================================================================================
                                                    SECTION
========================================================================================================== -->
\begin{section}{title= "<span style=text-transform:lowercase>3rd</span> Step: Calling R to Plot the Map"}

Once we've computed our statistics in Julia and identified countries by their ISO codes, the final step is to use R to create the heatmap. To accomplish this, we must first define a file path in Julia, where our graphs will be stored. If you run the code I provided, the folder will be located at `C:\maps\graph_folder`.

\codeblue{open}{Creating Path to Store the Graph}{\input{julia}{./code/region3a}}

To use R from within Julia, we need to convert the DataFrame into R's format. This can be done in two ways. The first option is to directly send `merged_df` to R, which will create an R's DataFrame in R with the same name. However, this option is only recommended if you plan to further manipulate the data in R, which is not our case. The second option is to simply interpolate `merged_df` when we reference it in R. 

Below, we provide the implementation of both options. After this, we'll exclusively use the second option, as it's simpler.



\hideTabs{open}{}{
<!-- #region -->
\html{
<div class="tab_wrapper">
 <div class="tab_code_links">
    <button class="tablink first_tab active" data-id=""> Sending Our DataFrame to R </button>
    <button class="tablink" data-id=""> Interpolating the DataFrame in R </button>
</div><div data-id="" class="tabcontent active">}

\Mcode{
\input{julia}{./code/region4}
}

\html{</div><div data-id="" class="tabcontent">}

\Mcode{
\input{julia}{./code/region5}
}

\html{</div></div>}
<!-- #endregion -->
}

We refer to this graph as the baseline case, since it uses the default layout provided by `ggplot2`. The difference between the approaches can be seen through the use of `@rput` or the interpolation of `merged_df`. In both options, though, `graphs_folder` is directly interpolated,  indicating to R where to store the graphs (we could've alternatively used `@rput` to send the variable `graphs_folder` to R).

The `fill` option constitutes the only information you need to fill in if you use this code as a template. It indicates the variable to be plotted, which is `share_income` in our case. The rest of the code should remain the same, regardless of what you wish to plot. In particular, `aes(x=long, y = lat, group = group)` must be specified in the same way every time you use it, as it provides the necessary information for drawing a world map. 

And that's it! You can use the code snippet as a template for your own graphs. The resulting graph is shown below. 

\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph0.svg}

As the baseline graph may not be visually appealing, we next provide further options to enhance its appearance. The final code we'll provide can also be used as a template that can be "copied and pasted", similar to the baseline script. 

\end{section}

<!-- =====================================================================================================
                                                    SECTION
========================================================================================================== -->
\begin{section}{title= "<span style=text-transform:lowercase>4rd</span> Step (optional): Tweaking the Graph"}

For each option added to the graph, we state the corresponding code and the resulting plot. We only change one option at a time, and you can skip the rest of this section if you wish to apply the code off the shelf. This code includes all the options we describe below, and produces the graph shown at the beginning of this note.

The codes and graphs are hidden by default. Press on "Code" to see the code, and on "Result" for the graph. Alternatively, press \kbd{Ctrl + 🠛} and \kbd{Ctrl + 🠙} to open and close all codes and graphs simultaneously. \\

<!-- SUBSECTION -->\subtitle{Getting Rid of Antarctica}

\code{closed}{\input{julia}{./code/region9}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01a.svg} \\


<!-- SUBSECTION -->\subtitle{Getting Rid of Axes, Grids, and Background}

We first define the following function using `RCall`:
\code{closed}{\input{julia}{./code/region11}}

And then plot the graph

\code{closed}{\input{julia}{./code/region12}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01b.svg} \\


<!-- SUBSECTION -->\subtitle{Changing Aspect Ratio}

\code{closed}{\input{julia}{./code/region13}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01c.svg} \\


<!-- SUBSECTION -->\subtitle{Changing Color Scale}

A quirky feature of `ggplot2` is that \textit{lighter colors} are associated with \textit{higher values}. The following code inverts the color scale, so that \textit{darker colors} correspond to \textit{higher values}.

\code{closed}{\input{julia}{./code/region14}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01d.svg} \\


<!-- SUBSECTION -->\subtitle{Changing Color of Borders}

\code{closed}{\input{julia}{./code/region15}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01e.svg} \\


<!-- SUBSECTION -->\subtitle{Cropping the Graph}

\code{closed}{\input{julia}{./code/region16}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01f.svg} \\

\end{section}


<!-- =====================================================================================================
                                                    SECTION
========================================================================================================== -->
\begin{section}{title= "Final Code that Includes All Options"}

You can use the following code off the shelf to plot a world heatmap. First, execute the following lines in Julia, without making any changes.

\code{closed}{\input{julia}{./code/region7}}

Then, execute the script below by only making two modifications: insert the name of your Julia DataFrame at the option `data`, and indicate the variable to be plotted at `fill`. In our example, these options respectively correspond to `merged_df2` (if we do not want to plot Antarctica, otherwise `merged_df`) and `share_income`.

\code{closed}{\input{julia}{./code/region8}}
\picDropPlain{closed}{left}{Plotted Graph}{50%}{ {{assets}}/graphs/file_graph01.svg}


\end{section}