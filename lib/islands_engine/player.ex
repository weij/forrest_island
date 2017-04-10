defmodule IslandsEngine.Player do
  defstruct name: :none, board: :none, island_set: :none

  alias IslandsEngine.{Board, IslandSet, Player}

  def start_link(name \\ :none) do
    with {:ok, board} = Board.start_link(),
         {:ok, island_set} = IslandSet.start_link() do
      Agent.start_link(fn -> %Player{name: name, board: board, island_set: island_set} end)       
    end
  end

  def set_name(player, name) do
    Agent.update(player, fn state -> Map.put(state, :name, name) end)
  end
  
  def set_island_coordinates(player, island, coordinates) do
    with board = get_board(player),
         island_set = get_island_set(player),
         coordinate_pids = convert_coordinates(board, coordinates) do
      IslandSet.set_island_coordinates(island_set, island, coordinate_pids)     
    end
  end

  def get_board(player) do
    Agent.get(player, fn state -> state.board end)
  end

  def get_island_set(player) do
    Agent.get(player, fn state -> state.island_set end)
  end

  def to_string(player) do
    "%Player{" <> string_body(player) <> "}"
  end

  defp convert_coordinates(board, coordinates) do
    Enum.map(coordinates, fn coord -> convert_coordinate(board, coord) end)
  end

  defp convert_coordinate(board, coordinate) when is_atom(coordinate) do
    Board.get_coordinate(board, coordinate)
  end

  defp convert_coordinate(_board, coordinate) when is_pid(coordinate) do
    coordinate
  end

  defp string_body(player) do
    state = Agent.get(player, &(&1))
    
    ":name => " <> name_to_string(state.name) <> ",\n" <>
    ":island_set => " <> IslandSet.to_string(state.island_set) <> ",\n" <>
    ":board => " <> Board.to_string(state.board)
  end

  defp name_to_string(:none), do: "none"
  defp name_to_string(name), do: name
end