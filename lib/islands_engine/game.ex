defmodule IslandsEngine.Game do
  defstruct player1: :none, player2: :none

  use GenServer

  alias IslandsEngine.{Game, Player}

  def call_demo(game) do
    GenServer.call(game, :demo)
  end

  def add_player(pid, name) when name != nil do
    GenServer.call(pid, {:add_player, name})
  end

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

end