defmodule TextBasedFPS.PlayerCommand.Fire do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.GameMap
  alias TextBasedFPS.Room
  alias TextBasedFPS.RoomPlayer
  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl PlayerCommand
  def execute(state, player, _) do
    require_alive_player(state, player, fn room ->
      room_player = Room.get_player(room, player.key)
      fire(state, room_player, room)
    end)
  end

  defp fire(state, %{ammo: {0, 0}}, _) do
    {:error, state, "You're out of ammo"}
  end

  defp fire(state, %{ammo: {0, _}}, _) do
    {:error, state, "Reload your gun by typing #{highlight("reload")}"}
  end

  defp fire(state, room_player, room) do
    shot_players = players_on_path(room.game_map.matrix, room_player.coordinates, room_player.direction)
    |> Enum.with_index
    |> Enum.map(fn {{shot_player_key, distance}, index} -> apply_damage(room, {shot_player_key, distance, index}) end)

    updated_state = ServerState.update_room(state, room.name, fn room ->
      shot_players
      |> Enum.reduce(room, fn shot_player, room -> apply_update(room, room_player, shot_player) end)
      |> Room.update_player(room_player.player_key, fn player -> RoomPlayer.decrease(player, :ammo) end)
    end)

    {:ok, updated_state, generate_message(state, shot_players)}
  end

  defp players_on_path(matrix, {x, y}, direction) do
    %{players: players} = GameMap.Matrix.iterate_towards(
      matrix,
      {x, y},
      direction,
      %{distance: 1, players: []},
      fn coordinate, acc ->
        cond do
          GameMap.Matrix.wall_at?(matrix, coordinate) ->
            {:stop, acc}

          GameMap.Matrix.player_at?(matrix, coordinate) ->
            player = GameMap.Matrix.at(matrix, coordinate)
            distance = acc.distance + 1

            updated_acc = acc
            |> Map.put(:distance, distance)
            |> Map.put(:players, acc.players ++ [{player.player_key, distance}])

            {:continue, updated_acc}

          true -> {:continue, acc}
        end
      end
    )

    players
  end

  defp apply_damage(room, {shot_player_key, distance_to_shooter, shot_player_order}) do
    shot_player = Room.get_player(room, shot_player_key)
    shoot_power = shoot_power(distance_to_shooter, shot_player_order)
    subtract_health(shot_player, shoot_power)
  end

  defp shoot_power(distance_to_shooter, enemy_index) do
    power = 30 - (distance_to_shooter - 1) - (enemy_index * 10)
    max(0, power)
  end

  defp subtract_health(shot_player, shoot_power) do
    new_health = max(0, shot_player.health - shoot_power)
    Map.put(shot_player, :health, new_health)
  end

  defp apply_update(room, shooter, shot_player) do
    coordinates = shot_player.coordinates

    Room.update_player(room, shot_player.player_key, shot_player)
    |> maybe_remove_player_from_map(shot_player)
    |> maybe_add_item(shot_player, coordinates)
    |> maybe_update_score(shooter, shot_player)
  end

  defp maybe_remove_player_from_map(room, shot_player = %{health: 0}) do
    Room.remove_player_from_map(room, shot_player.player_key)
  end
  defp maybe_remove_player_from_map(room, _shot_player), do: room

  defp maybe_add_item(room, _shot_player = %{health: 0}, coordinates) do
    Room.add_random_object(room, coordinates)
  end
  defp maybe_add_item(room, _shot_player, _coordinates), do: room

  defp maybe_update_score(room, shooter, shot_player = %{health: 0}) do
    room
    |> Room.update_player(shooter.player_key, &(RoomPlayer.increase(&1, :kills)))
    |> Room.update_player(shot_player.player_key, &(RoomPlayer.increase(&1, :killed)))
  end
  defp maybe_update_score(room, _shooter, _shot_player), do: room
  defp generate_message(_state, []) do
    "You've shot the wall."
  end

  defp generate_message(state, shot_players) do
    killed = Enum.filter(shot_players, &RoomPlayer.dead?/1)
    hit = shot_players -- killed

    phrase_parts = [action_message("hit", state, hit), action_message("killed", state, killed)]
    |> Stream.filter(fn part -> part != nil end)
    |> Enum.join(" and ")

    "You've #{phrase_parts}"
  end

  defp action_message(verb, state, shot_players) do
    names = shot_players
    |> Stream.map(fn shot -> ServerState.get_player(state, shot.player_key) end)
    |> Enum.map(&(&1.name))

    case length(names) do
      0 -> nil
      _ -> "#{verb} #{Enum.join(names, ", ")}"
    end
  end
end
