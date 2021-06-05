defmodule  TextBasedFPS.Room do
  alias TextBasedFPS.Room
  alias TextBasedFPS.RoomPlayer
  alias TextBasedFPS.GameMap

  @type t :: %TextBasedFPS.Room{
    name: String.t,
    game_map: TextBasedFPS.GameMap.t,
    players: list(TextBasedFPS.RoomPlayer.t)
  }

  defstruct [:name, :game_map, :players]

  def new(name) do
    %Room{
      name: name,
      game_map: GameMap.build(),
      players: %{}
    }
  end

  def add_player(room, player_key) do
    put_in(room.players[player_key], RoomPlayer.build(player_key))
    |> respawn_player(player_key)
  end

  def remove_player(room, player_key) do
    remove_player_from_map(room, player_key)
    |> Map.put(:players, Map.delete(room.players, player_key))
  end

  def add_random_object(room, {x, y}) do
    object = Enum.random(GameMap.Objects.all())
    update_game_map_matrix(room, {x, y}, object.new())
  end

  def respawn_player(room, player_key) do
    room_player = get_player(room, player_key)
    respawn_player(room, room_player, RoomPlayer.dead?(room_player))
  end
  def respawn_player(room, _room_player, false), do: {:error, room, :player_is_alive}
  def respawn_player(room, room_player, true) do
    %{coordinates: coordinates, direction: direction} = GameMap.RespawnPosition.find_respawn_position(room)
    {:ok, room, _} = place_player_at(room, room_player.player_key, coordinates)
    room = update_player(room, room_player.player_key, fn player ->
      player
      |> Map.put(:direction, direction)
      |> Map.put(:health, RoomPlayer.max_health)
      |> Map.put(:ammo, {RoomPlayer.max_loaded_ammo, RoomPlayer.max_unloaded_ammo})
    end)
    {:ok, room}
  end

  def place_player_at(room, player_key, {x, y}) do
    matrix = room.game_map.matrix

    cond do
      # do nothing if player is already there
      GameMap.Matrix.player_at?(matrix, {x, y}, player_key) -> {:ok, room}

      # can't walk over a wall
      GameMap.Matrix.wall_at?(matrix, {x, y}) -> {:error, room}

      # can't walk over another player
      GameMap.Matrix.player_at?(matrix, {x, y}) -> {:error, room}

      # if there's an object in there, grab it
      GameMap.Matrix.object_at?(matrix, {x, y}) ->
        object = GameMap.Matrix.at(matrix, {x, y})
        room
        |> update_player(player_key, fn player -> GameMap.Object.grab(object, player) end)
        |> move_player(player_key, {x, y}, object)

      true ->
        move_player(room, player_key, {x, y}, nil)
    end
  end
  defp move_player(room, player_key, coordinates, object_grabbed) do
    room = room
    |> remove_player_from_map(player_key)
    |> update_player(player_key, fn player -> Map.put(player, :coordinates, coordinates) end)
    |> update_game_map_matrix(fn matrix ->
      GameMap.Matrix.set(matrix, coordinates, GameMap.Objects.Player.new(player_key))
    end)

    {:ok, room, object_grabbed}
  end

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

  def get_player(room, player_key), do: room.players[player_key]

  def update_player(room, player_key, fun) when is_function(fun) do
    updated_player = get_player(room, player_key) |> fun.()
    put_in(room.players[player_key], updated_player)
  end
  def update_player(room, player_key, room_player) when is_map(room_player) do
    put_in(room.players[player_key], room_player)
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

  def validate_name(name) do
    cond do
      String.length(name) > 20 -> {:error, "Room name cannot exceed 20 characters"}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, "Room name can only contain letters, numbers and hyphens."}
      true -> :ok
    end
  end
end
