defmodule TextBasedFPS.Process.Players do
  alias TextBasedFPS.Player

  use Agent

  @type state :: %{Player.key_t() => Player.t()}

  @spec start_link(state) :: Agent.on_start()
  def start_link(players \\ %{}) do
    Agent.start_link(fn -> players end, name: __MODULE__)
  end

  @spec add_player() :: :ok
  def add_player, do: add_player(Player.generate_key())

  @spec add_player(Player.key_t()) :: :ok
  def add_player(player_key) do
    Agent.update(__MODULE__, fn players ->
      if Map.has_key?(players, player_key) do
        players
      else
        Map.put(players, player_key, Player.new(player_key))
      end
    end)
  end

  @spec get_player(Player.key_t()) :: Player.t() | nil
  def get_player(player_key), do: Agent.get(__MODULE__, &Map.get(&1, player_key))

  @spec update_player(Player.key_t(), (Player.t() -> Player.t())) :: :ok
  def update_player(player_key, fun) do
    Agent.update(__MODULE__, fn players ->
      if Map.has_key?(players, player_key) do
        Map.update!(players, player_key, fun)
      else
        players
      end
    end)
  end

  @spec remove_player(Player.key_t()) :: :ok
  def remove_player(player_key), do: Agent.update(__MODULE__, &Map.delete(&1, player_key))

  @spec get_all_players() :: list(Player.t())
  def get_all_players, do: Agent.get(__MODULE__, & &1)
end
