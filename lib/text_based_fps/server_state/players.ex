defmodule TextBasedFPS.ServerState.Players do
  alias TextBasedFPS.{Player, ServerState}

  @spec add_player(ServerState.t()) :: {Player.key_t(), ServerState.t()}
  def add_player(state) do
    key = Player.generate_key()
    {key, ServerState.add_player(state, key)}
  end

  @spec add_player(ServerState.t(), Player.key_t()) :: ServerState.t()
  def add_player(state, key) do
    if Map.has_key?(state.players, key) do
      state
    else
      put_in(state.players[key], Player.new(key))
    end
  end

  @spec update_player(ServerState.t(), Player.key_t(), function) :: ServerState.t()
  def update_player(state, player_key, fun) do
    player = get_player(state, player_key)

    if player do
      updated_player = fun.(player)
      put_in(state.players[player_key], updated_player)
    else
      state
    end
  end

  @spec remove_player(ServerState.t(), Player.key_t()) :: ServerState.t()
  def remove_player(state, player_key) do
    state
    |> ServerState.Rooms.remove_player_from_current_room(player_key)
    |> Map.put(:players, Map.delete(state.players, player_key))
  end

  @spec get_player(ServerState.t(), Player.key_t()) :: Player.t() | nil
  def get_player(state, player_key), do: state.players[player_key]
end
