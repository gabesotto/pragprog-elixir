defmodule IslandsEngine.Rules do
  alias __MODULE__

  defstruct state: :initialized,
    player1: :islands_not_set,
    player2: :islands_not_set

  def new() do
    %Rules{}
  end

  # :player2_turn -> :game_over
  def check(%Rules{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  # Player 2's turn to make a guess -> Player 1's turn
  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end

  # :player1_turn -> :game_over
  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  # Player 1's turn to make a guess -> Player 2's turn
  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end

  # player's islands are set, check if we should move to :player1_turn
  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)
    case both_players_islands_set?(rules) do
      true  -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  # check if a player is allowed to position his/her islands
  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  # :initalized -> :players_set
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  # Fallback, return error
  def check(_state, _action) do
    :error
  end

  ## private functions
  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set && rules.player2 ==  :islands_set
  end
end
