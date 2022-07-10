defmodule TextBasedFPS.Room do
  alias TextBasedFPS.{
    GameMap,
    Player,
    Room,
    RoomPlayer
  }

  alias TextBasedFPS.GameMap.Object

  defstruct [:name, :game_map, :players]

  @type t :: %TextBasedFPS.Room{
          name: String.t(),
          game_map: TextBasedFPS.GameMap.t(),
          players: %{Player.key_t() => TextBasedFPS.RoomPlayer.t()}
        }

  @name_max_length 20

  @spec new(String.t()) :: t
  def new(name) do
    %Room{
      name: name,
      game_map: GameMap.new(),
      players: %{}
    }
  end

  @spec add_player(t, Player.key_t()) :: {:ok, t} | {:error, t, :room_full}
  def add_player(room, player_key) do
    if Enum.count(room.players) == Enum.count(room.game_map.respawn_positions) do
      {:error, room, :room_full}
    else
      put_in(room.players[player_key], RoomPlayer.new(player_key))
      |> respawn_player(player_key)
    end
  end

  @spec add_player!(t, Player.key_t()) :: t
  def add_player!(room, player_key) do
    case add_player(room, player_key) do
      {:ok, updated_room} -> updated_room
      {:error, _room, reason} -> raise("Cannot add player. Reason: #{reason}")
    end
  end

  @spec remove_player(t, Player.key_t()) :: t
  def remove_player(room, player_key) do
    remove_player_from_map(room, player_key)
    |> Map.put(:players, Map.delete(room.players, player_key))
  end

  @spec add_random_object(t, GameMap.Coordinates.t()) :: t
  def add_random_object(room, {x, y}) do
    object = Enum.random(GameMap.Objects.all())
    add_object(room, {x, y}, object)
  end

  @spec add_object(t, GameMap.Coordinates.t(), Object.t()) :: t
  def add_object(room, {x, y}, object) do
    update_game_map_matrix(room, {x, y}, object.new())
  end

  @spec respawn_player(t, Player.key_t()) :: {:ok, t} | {:error, :player_is_alive}
  def respawn_player(room, player_key) do
    room_player = get_player(room, player_key)
    respawn_player(room, room_player, RoomPlayer.dead?(room_player))
  end

  defp respawn_player(_room, _room_player, false), do: {:error, :player_is_alive}

  defp respawn_player(room, room_player, true) do
    %{coordinates: coordinates, direction: direction} =
      GameMap.RespawnPosition.find_respawn_position(room)

    room =
      room
      |> place_player_at!(room_player.player_key, coordinates)
      |> update_player(room_player.player_key, fn player ->
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

  @spec place_player_at!(t, Player.key_t(), GameMap.Coordinates.t()) :: TextBasedFPS.Room.t()
  def place_player_at!(room, player_key, {x, y}) do
    case place_player_at(room, player_key, {x, y}) do
      {:ok, updated_room, _object_grabbed} -> updated_room
      {:error, _room} -> raise("Cannot place player #{player_key} at (#{x}, #{y})")
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
      String.length(name) > @name_max_length -> {:error, :too_large}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, :invalid_chars}
      true -> :ok
    end
  end

  @spec name_max_length() :: non_neg_integer()
  def name_max_length, do: @name_max_length

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
