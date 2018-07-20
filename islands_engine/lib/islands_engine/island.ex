defmodule IslandsEngine.Island do
  alias IslandsEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  def new(type, %Coordinate{} = upper_left) do
    with [_h|_t] = offsets <- offsets(type),  #Check that offsets returns a list
      %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) #Check that add_coordinates returns a Mapset
    do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  #Return a list of island types
  def types() do
    [:atoll, :dot, :square, :l_shape, :s_shape]
  end

  # Do two islands overlap?
  def overlaps?(existing_island, new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  # Is the `coordinate` on this `island`?
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true -> {:hit, update_in(island.hit_coordinates, &MapSet.put(&1, coordinate))}
      false -> :miss
    end
  end

  #Is the island forested?
  def forested?(island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(
      offsets,
      MapSet.new(),
      fn offset, acc ->
        add_coordinates(acc, upper_left, offset)
      end)
  end

  defp add_coordinates(
    coordinates,
    %Coordinate{row: row, col: col},
    {row_offset, col_offset}
  ) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} -> {:halt, {:error, :invalid_coordinates}}
    end
  end

  defp offsets(:square) do
    [{0,0}, {0,1}, {1,0}, {1,1}]
  end

  defp offsets(:atoll) do
    [{0,0}, {0,1}, {1,1}, {2,0}, {2,1}]
  end

  defp offsets(:dot) do
    [{0,0}]
  end

  defp offsets(:l_shape) do
    [{0,0}, {1,0}, {2,0}, {2,1}]
  end

  defp offsets(:s_shape) do
    [{0,1},{0,2},{1,0}, {1,1}]
  end

  defp offsets(_) do
    {:error, :invalid_island_type}
  end
end
