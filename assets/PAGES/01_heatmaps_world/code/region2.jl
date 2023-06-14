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