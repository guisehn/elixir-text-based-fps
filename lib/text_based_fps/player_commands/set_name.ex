defmodule TextBasedFPS.PlayerCommand.SetName do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState
  import TextBasedFPS.PlayerCommand.Util

  @behaviour PlayerCommand

  @impl PlayerCommand
  def execute(state, player, name) do
    name = String.trim(name)

    case validate_name(state, name) do
      :ok ->
        state = update_name(state, player, name)
        {:ok, state, success_message(state.players[player.key])}
      {:error, reason} -> {:error, state, reason}
    end
  end

  defp validate_name(state, name) do
    cond do
      String.length(name) > 20 -> {:error, "Name cannot exceed 20 characters"}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, "Name can only contain letters, numbers and hyphens."}
      name_exists?(state, name) -> {:error, "Name is already in use"}
      true -> :ok
    end
  end

  defp update_name(state, player, name) do
    ServerState.update_player(
      state,
      player.key,
      fn player -> Map.put(player, :name, name) end
    )
  end

  defp name_exists?(state, name) do
    Enum.any?(state.players, fn {_, player} -> player.name == name end)
  end

  defp success_message(%{name: name, room: nil}) do
    "Your name is now #{name}. Now, type #{highlight("join-room <room-name>")} to join a room."
  end
  defp success_message(%{name: name}) do
    "Your name is now #{name}."
  end
end
