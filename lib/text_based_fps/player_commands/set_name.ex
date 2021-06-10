defmodule TextBasedFPS.PlayerCommand.SetName do
  alias TextBasedFPS.Player
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  import TextBasedFPS.Text, only: [highlight: 1]

  @behaviour PlayerCommand

  @impl true
  def execute(state, player, name) do
    name = String.trim(name)

    case Player.validate_name(state, name) do
      :ok ->
        state = state |> notify_room(player, name) |> update_name(player, name)
        {:ok, state, success_message(state.players[player.key])}

      {:error, reason} ->
        {:error, state, error_message(reason)}
    end
  end

  defp update_name(state, player, name) do
    ServerState.update_player(
      state,
      player.key,
      fn player -> Map.put(player, :name, name) end
    )
  end

  defp notify_room(state, player, new_name), do: notify_room(state, player, new_name, player.room)
  defp notify_room(state, _player, _new_name, nil), do: state
  defp notify_room(state, player, new_name, room_name) do
    body = highlight("#{player.name} changed their name to #{new_name}")
    ServerState.notify_room_except_player(state, room_name, player.key, body)
  end

  defp success_message(%{name: name, room: nil}) do
    "Your name is now #{name}. Now, type #{highlight("join-room <room-name>")} to join a room."
  end
  defp success_message(%{name: name}) do
    "Your name is now #{name}."
  end

  defp error_message(:empty) do
    "Name cannot be empty"
  end
  defp error_message(:too_large) do
    "Name cannot exceed 20 characters"
  end
  defp error_message(:invalid_chars) do
    "Name can only contain letters, numbers and hyphens."
  end
  defp error_message(:already_in_use) do
    "Name is already in use"
  end
end
