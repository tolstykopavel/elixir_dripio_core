alias Dripio.Location

locs = Dripio.Repo.all(Location)

locs
|> Enum.each(fn l ->
  IO.inspect(Dripio.Repo.update(Location.change_location(l, %{address: nil})))
end)
