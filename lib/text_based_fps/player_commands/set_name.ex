defmodule TextBasedFPS.PlayerCommand.SetName do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.{Player, PlayerCommand, ServerState}

  @behaviour PlayerCommand

  @error_messages %{
    already_in_use: "Name is already in use",
    empty: "Name cannot be empty",
    invalid_chars: "Name can only contain letters, numbers and hyphens.",
    too_large: "Name cannot exceed #{Player.name_max_length()} characters"
  }

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

  @spec error_message(atom) :: String.t()
  defp error_message(reason) do
    @error_messages[reason] || "Error: #{reason}"
  end
end
