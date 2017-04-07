defmodule IslandsEngine.Game do
  defstruct player1: :none, player2: :none

  use GenServer

  alias IslandsEngine.{Game, Player}

  def call_demo(game) do
    GenServer.call(game, :demo)
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

end