defmodule IslandsEngine.Game do
  defstruct player1: :none, player2: :none

  use GenServer

  alias IslandsEngine.{Game, Player}

  # API

  def call_demo(game) do
    GenServer.call(game, :demo)
  end

  def add_player(pid, name) when name != nil do
    GenServer.call(pid, {:add_player, name})
  end
  
  @doc """
    Set a particular type of island for :player1 or :player2
    
  Example:
    iex> Game.set_island_coordinates(pid, :player1, :dot, [:a1])
  """
  def set_island_coordinates(pid, player, island, coordinates) 
    when is_atom(player) and is_atom(island) do
    GenServer.call(pid, {:set_island_coordinates, player, island, coordinates})
  end

  def guess_coordinate(pid, player, coordinate) when is_atom(player) and is_atom(coordinate) do
    GenServer.call(pid, {:guess, player, coordinate})
  end

  # CALLBACKS

  def start_link(name) when not is_nil(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    with {:ok, player1} = Player.start_link(name),
         {:ok, player2} = Player.start_link() do
      {:ok, %Game{player1: player1, player2: player2}}     
    end
  end

  def handle_call(:demo, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:add_player, name}, _from, state) do
    Player.set_name(state.player2, name)
    {:reply, :ok, state}
  end

  def handle_call({:set_island_coordinates, player, island, coordinates}, _from, state) do
    state
    |> Map.get(player)
    |> Player.set_island_coordinates(island, coordinates)

    {:reply, :ok, state}
  end

  def handle_call({:guess, player, coordinate}, _from, state) do
    response = 
      state
      |> opponent(player)
      |> Player.get_board()
      |> Player.guess_coordinate(coordinate)
    {:reply, response, state}
  end

  defp opponent(state, :player1), do: state.player2
  defp opponent(state, _player), do: state.player1  
  
end