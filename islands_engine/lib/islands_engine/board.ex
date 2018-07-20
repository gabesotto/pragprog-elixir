defmodule IslandsEngine.Board do
alias IslandsEngine.{Island, Coordinate}

  def new() do
    %{}
  end

  # Given a guess and state of the board return a new board state with 4 things:
  # {
  #   :hit/miss,
  #   :none or :type (of island IF FORESTED)
  #   :win/:no_win
  #   the board
  # }
  def guess(board, coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  # given an island to position, add it to our board or return an error if
  # it overlaps an existing island
  def position_island(board, key, %Island{} = island) do
    case overlaps_exisiting_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  # Are all of the island set on the board?
  def all_islands_positioned?(board) do
    Enum.all?(Island.types(), &Map.has_key?(board, &1))
  end

  # if our win condition is met :win otherwise :no_win
  def win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  # is every island on the board forested? (Our win condition)
  def all_forested?(board) do
    Enum.all?(board, fn{_key, island} ->
      Island.forested?(island)
    end)
  end

  # given a response from check_all_islands(), make our guess response
  #hit
  defp guess_response({key, island}, board) do
    board = Map.put(board, key, island)
    {:hit, forested_check(board, key), win_check(board), board}
  end

  #miss
  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  # check if an island is forested
  defp forested_check(board, key) do
    case forested?(board, key) do
      true  -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  # check every island with a guess, return :hit with the new island or :miss
  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn{key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  # Does a given island overlap all the other existing islands on the board?
  defp overlaps_exisiting_island?(board, new_key, new_island) do
    Enum.any?(
      board,
      fn{key, island} ->
        key != new_key and Island.overlaps?(island, new_island)
      end)
  end
end
