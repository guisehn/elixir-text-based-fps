defmodule TextBasedFPS.Game.Command.SetName do
  alias TextBasedFPS.Game.{Command, Player, Notifications}
  alias TextBasedFPS.{GameState, Text}

  @behaviour Command

  @impl true
  def arg_example, do: "new name"

  @impl true
  def description, do: "Change your name"

  @impl true
  def execute(player, name) do
    name = String.trim(name)

    with :ok <- Player.validate_name(name),
         :ok <- ensure_not_used?(name) do
      notify_room(player, name)
      player = GameState.update_player(player.key, &Map.put(&1, :name, name))
      {:ok, success_message(player)}
    else
      {:error, reason} ->
        {:error, error_message(reason)}
    end
  end

  defp ensure_not_used?(name) do
    unless GameState.player_name_exists?(name) do
      :ok
    else
      {:error, :already_in_use}
    end
  end

  defp notify_room(%Player{room: room} = player, new_name) when not is_nil(room) do
    msg = Text.highlight("#{player.name} changed their name to #{new_name}")
    Notifications.notify_room(room, msg, except: [player.key])
  end

  defp notify_room(_player, _new_name), do: nil

  defp success_message(%Player{name: name, room: nil}) do
    "Your name is now #{name}. Now, type #{Text.highlight("join-room <room-name>")} to join a room."
  end

  defp success_message(%Player{name: name}) do
    "Your name is now #{name}."
  end

  @error_messages %{
    already_in_use: "Name is already in use",
    empty: "Name cannot be empty",
    invalid_chars: "Name can only contain letters, numbers and hyphens.",
    too_large: "Name cannot exceed #{Player.name_max_length()} characters"
  }
  @spec error_message(atom) :: String.t()
  defp error_message(reason) do
    @error_messages[reason] || "Error: #{reason}"
  end
end
