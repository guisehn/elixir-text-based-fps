defmodule TextBasedFPS.Game.Command.Fire do
  import TextBasedFPS.Game.CommandHelper

  alias TextBasedFPS.{GameMap, GameState, Text}
  alias TextBasedFPS.Game.{Command, Notifications, Room, RoomPlayer}

  @behaviour Command

  @impl true
  def description, do: "Shoot towards your current direction"

  @impl true
  def execute(player, _) do
    with {:ok, room} <- require_alive_player(player) do
      room_player = Room.get_player(room, player.key)
      fire(player, room_player, room)
    end
  end

  defp fire(_, %{ammo: {0, 0}}, _) do
    {:error, "You're out of ammo"}
  end

  defp fire(_, %{ammo: {0, _}}, _) do
    {:error, "Reload your gun by typing #{Text.highlight("reload")}"}
  end

  defp fire(player, room_player, room) do
    shot_players =
      players_on_path(room.game_map.matrix, room_player.coordinates, room_player.direction)
      |> Enum.with_index()
      |> Enum.map(fn {{shot_player_key, distance}, index} ->
        apply_damage(room, {shot_player_key, distance, index})
      end)

    GameState.update_room(room.name, fn room ->
      shot_players
      |> Enum.reduce(room, fn shot_player, room ->
        apply_update(room, room_player, shot_player)
      end)
      |> Room.update_player(room_player.player_key, fn player ->
        RoomPlayer.decrement(player, :ammo)
      end)
    end)

    push_notifications(player, shot_players)

    {:ok, generate_message(shot_players)}
  end

  defp players_on_path(matrix, {x, y}, direction) do
    %{players: players} =
      GameMap.Matrix.iterate_towards(
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

              updated_acc =
                acc
                |> Map.put(:players, acc.players ++ [{player.player_key, acc.distance}])
                |> Map.put(:distance, acc.distance + 1)

              {:continue, updated_acc}

            true ->
              {:continue, Map.put(acc, :distance, acc.distance + 1)}
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
    power = 30 - (distance_to_shooter - 1) - enemy_index * 10
    max(0, power)
  end

  defp subtract_health(shot_player, shoot_power) do
    new_health = max(0, shot_player.health - shoot_power)
    Map.put(shot_player, :health, new_health)
  end

  defp apply_update(room, shooter, shot_player) do
    coordinates = shot_player.coordinates

    put_in(room.players[shot_player.player_key], shot_player)
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
    |> Room.update_player(shooter.player_key, &RoomPlayer.increment(&1, :kills))
    |> Room.update_player(shot_player.player_key, &RoomPlayer.increment(&1, :killed))
  end

  defp maybe_update_score(room, _shooter, _shot_player), do: room

  defp generate_message([]) do
    "You've shot the wall."
  end

  defp generate_message(shot_players) do
    killed = Enum.filter(shot_players, &RoomPlayer.dead?/1)
    hit = shot_players -- killed

    phrase_parts =
      [action_message("hit", hit), action_message("killed", killed)]
      |> Stream.filter(fn part -> part != nil end)
      |> Enum.join(" and ")

    "You've #{phrase_parts}"
  end

  defp action_message(verb, shot_players) do
    names =
      shot_players
      |> Stream.map(fn shot -> GameState.get_player(shot.player_key) end)
      |> Enum.map(& &1.name)

    case length(names) do
      0 -> nil
      _ -> "#{verb} #{Enum.join(names, ", ")}"
    end
  end

  defp push_notifications(shooter_player, shot_players) do
    Enum.each(shot_players, fn shot_player ->
      msg = generate_shot_message(shooter_player, shot_player)
      Notifications.notify(shot_player.player_key, msg)
    end)
  end

  defp generate_shot_message(shooter_player, %{health: 0} = _shot_player) do
    Text.danger(
      "#{shooter_player.name} killed you! Type #{Text.highlight("respawn")} to return to the game"
    )
  end

  defp generate_shot_message(shooter_player, _shot_player) do
    Text.danger("uh oh! #{shooter_player.name} shot you!")
  end
end
