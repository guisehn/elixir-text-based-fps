defmodule TextBasedFPS.GameState.Players do
  @moduledoc "An agent that keeps track of all players of the server"

  alias TextBasedFPS.Game.Player

  use Agent

  @type state :: %{Player.key_t() => Player.t()}

  @spec start_link(state) :: Agent.on_start()
  def start_link(players \\ %{}) do
    Agent.start_link(fn -> players end, name: process_ref())
  end

  def stop, do: Agent.stop(process_ref())

  @spec add_player() :: :ok
  def add_player, do: add_player(Player.generate_key())

  @spec add_player(Player.key_t()) :: :ok
  def add_player(player_key) do
    Agent.update(process_ref(), fn players ->
      if Map.has_key?(players, player_key) do
        players
      else
        Map.put(players, player_key, Player.new(player_key))
      end
    end)
  end

  @spec get_player(Player.key_t()) :: Player.t() | nil
  def get_player(player_key), do: Agent.get(process_ref(), &Map.get(&1, player_key))

  @spec update_player(Player.key_t(), (Player.t() -> Player.t())) :: Player.t() | nil
  def update_player(player_key, fun) do
    Agent.get_and_update(process_ref(), fn players ->
      players = Map.update(players, player_key, nil, fun)
      {Map.get(players, player_key), players}
    end)
  end

  @spec remove_player(Player.key_t()) :: :ok
  def remove_player(player_key), do: Agent.update(process_ref(), &Map.delete(&1, player_key))

  @spec get_all_players() :: list(Player.t())
  def get_all_players, do: Agent.get(process_ref(), & &1)

  @spec player_name_exists?(String.t()) :: boolean
  def player_name_exists?(name) do
    Agent.get(process_ref(), fn players ->
      Enum.any?(players, fn {_, player} -> player.name == name end)
    end)
  end

  defp process_ref, do: Process.get(__MODULE__, __MODULE__)

  def setup_local_process_ref, do: Process.put(__MODULE__, :"#{__MODULE__}_#{inspect(self())}")
end
