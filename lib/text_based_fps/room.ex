defmodule TextBasedFPS.Room do
  alias TextBasedFPS.Player
  alias TextBasedFPS.Room
  alias TextBasedFPS.RoomPlayer
  alias TextBasedFPS.GameMap

  @type t :: %TextBasedFPS.Room{
          name: String.t(),
          game_map: TextBasedFPS.GameMap.t(),
          players: %{String.t() => TextBasedFPS.RoomPlayer.t()}
        }

  defstruct [:name, :game_map, :players]

  @spec new(String.t()) :: t
  def new(name) do
    %Room{
      name: name,
      game_map: GameMap.new(),
      players: %{}
    }
  end

  @spec add_player(t, Player.key_t()) :: t
  def add_player(room, player_key) do
    {:ok, room} =
      put_in(room.players[player_key], RoomPlayer.new(player_key))
      |> respawn_player(player_key)

    room
  end

  @spec remove_player(t, Player.key_t()) :: t
  def remove_player(room, player_key) do
    remove_player_from_map(room, player_key)
    |> Map.put(:players, Map.delete(room.players, player_key))
  end

  @spec add_random_object(t, GameMap.Coordinates.t()) :: t
  def add_random_object(room, {x, y}) do
    object = Enum.random(GameMap.Objects.all())
    update_game_map_matrix(room, {x, y}, object.new())
  end

  @spec respawn_player(t, Player.key_t()) :: {:ok, t} | {:error, t, :player_is_alive}
  def respawn_player(room, player_key) do
    room_player = get_player(room, player_key)
    respawn_player(room, room_player, RoomPlayer.dead?(room_player))
  end

  defp respawn_player(room, _room_player, false), do: {:error, room, :player_is_alive}

  defp respawn_player(room, room_player, true) do
    %{coordinates: coordinates, direction: direction} =
      GameMap.RespawnPosition.find_respawn_position(room)

    {:ok, room, _} = place_player_at(room, room_player.player_key, coordinates)

    room =
      update_player(room, room_player.player_key, fn player ->
        player
        |> Map.put(:direction, direction)
        |> Map.put(:health, RoomPlayer.max_health())
        |> Map.put(:ammo, {RoomPlayer.max_loaded_ammo(), RoomPlayer.max_unloaded_ammo()})
      end)

    {:ok, room}
  end

  @spec place_player_at(t, Player.key_t(), GameMap.Coordinates.t()) ::
          {:ok, t, GameMap.Object.t()} | {:error, t}
  def place_player_at(room, player_key, {x, y}) do
    matrix = room.game_map.matrix

    cond do
      # do nothing if player is already there
      GameMap.Matrix.player_at?(matrix, {x, y}, player_key) ->
        {:ok, room, nil}

      # can't walk over a wall
      GameMap.Matrix.wall_at?(matrix, {x, y}) ->
        {:error, room}

      # can't walk over another player
      GameMap.Matrix.player_at?(matrix, {x, y}) ->
        {:error, room}

      # if there's an object in there, grab it
      GameMap.Matrix.object_at?(matrix, {x, y}) ->
        object = GameMap.Matrix.at(matrix, {x, y})

        room
        |> update_player(player_key, fn player -> GameMap.Object.grab(object, player) end)
        |> move_player(player_key, {x, y}, object)

      GameMap.Matrix.has?(matrix, {x, y}) ->
        move_player(room, player_key, {x, y}, nil)

      true ->
        {:error, room}
    end
  end

  defp move_player(room, player_key, coordinates, object_grabbed) do
    room =
      room
      |> remove_player_from_map(player_key)
      |> update_player(player_key, fn player -> Map.put(player, :coordinates, coordinates) end)
      |> update_game_map_matrix(fn matrix ->
        GameMap.Matrix.set(matrix, coordinates, GameMap.Objects.Player.new(player_key))
      end)

    {:ok, room, object_grabbed}
  end

  @spec remove_player_from_map(t, Player.key_t()) :: t
  def remove_player_from_map(room, player_key) do
    room_player = get_player(room, player_key)
    remove_player_from_map(room, player_key, room_player.coordinates)
  end

  defp remove_player_from_map(room, _player_key, nil), do: room

  defp remove_player_from_map(room, player_key, {x, y}) do
    room
    |> update_game_map_matrix(fn matrix -> GameMap.Matrix.clear(matrix, {x, y}) end)
    |> update_player(player_key, fn player -> Map.put(player, :coordinates, nil) end)
  end

  @spec kill_player(t, Player.key_t()) :: t
  def kill_player(room, player_key) do
    room
    |> remove_player_from_map(player_key)
    |> update_player(player_key, fn player -> Map.put(player, :health, 0) end)
  end

  @spec get_player(t, Player.key_t()) :: RoomPlayer.t() | nil
  def get_player(room, player_key), do: room.players[player_key]

  @spec update_player(t, Player.key_t(), function) :: t
  def update_player(room, player_key, fun) when is_function(fun) do
    updated_player = get_player(room, player_key) |> fun.()
    put_in(room.players[player_key], updated_player)
  end

  @spec update_player(t, Player.key_t(), RoomPlayer.t()) :: t
  def update_player(room, player_key, room_player) when is_map(room_player) do
    put_in(room.players[player_key], room_player)
  end

  @spec validate_name(String.t()) ::
          :ok | {:error, :empty} | {:error, :too_large} | {:error, :invalid_chars}
  def validate_name(name) do
    cond do
      name == "" -> {:error, :empty}
      String.length(name) > 20 -> {:error, :too_large}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, :invalid_chars}
      true -> :ok
    end
  end

  defp update_game_map(room, fun) do
    Map.put(room, :game_map, fun.(room.game_map))
  end

  defp update_game_map_matrix(room, fun) do
    update_game_map(room, fn game_map -> GameMap.update_matrix(game_map, fun) end)
  end

  defp update_game_map_matrix(room, {x, y}, value) do
    update_game_map_matrix(room, fn matrix -> GameMap.Matrix.set(matrix, {x, y}, value) end)
  end
end
