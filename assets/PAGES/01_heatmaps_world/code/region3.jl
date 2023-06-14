# we merge our dataframe with the file having map coordinates
link           = Downloads.download("https://alfaromartino.github.io/data/countries_mapCoordinates.csv")
df_coordinates = DataFrame(CSV.File(link)) |> x-> dropmissing(x, :iso3)

merged_df = leftjoin(df_coordinates, our_df, on=:iso3)
println(merged_df[15_000:15_000:70_000, Not([:sovereignty, :subregion])]) #hide