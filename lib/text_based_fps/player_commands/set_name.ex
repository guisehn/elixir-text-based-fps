defmodule TextBasedFPS.PlayerCommand.SetName do
  import TextBasedFPS.Text, only: [highlight: 1]

  alias TextBasedFPS.{Player, PlayerCommand, ServerAgent}
  alias TextBasedFPS.Process.Players

  @behaviour PlayerCommand

  @error_messages %{
    already_in_use: "Name is already in use",
    empty: "Name cannot be empty",
    invalid_chars: "Name can only contain letters, numbers and hyphens.",
    too_large: "Name cannot exceed #{Player.name_max_length()} characters"
  }

  @impl true
  def execute(player, name) do
    name = String.trim(name)

    IO.inspect(player, label: "== player ==")

    case Player.validate_name(name) do
      :ok ->
        notify_room(player, name)
        player = Players.update_player(player.key, &Map.put(&1, :name, name))
        {:ok, success_message(player)}

      {:error, reason} ->
        {:error, error_message(reason)}
    end
  end

  defp notify_room(%Player{room: room} = player, new_name) when not is_nil(room) do
    body = highlight("#{player.name} changed their name to #{new_name}")
    ServerAgent.notify_room_except_player(room, player.key, body)
  end

  defp notify_room(_player, _new_name), do: nil

  defp success_message(%Player{name: name, room: nil}) do
    "Your name is now #{name}. Now, type #{highlight("join-room <room-name>")} to join a room."
  end

  defp success_message(%Player{name: name}) do
    "Your name is now #{name}."
  end

  @spec error_message(atom) :: String.t()
  defp error_message(reason) do
    @error_messages[reason] || "Error: #{reason}"
  end
end
