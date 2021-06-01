defmodule TextBasedFPS.PlayerCommand.SetName do
  alias TextBasedFPS.PlayerCommand
  alias TextBasedFPS.ServerState

  @behaviour PlayerCommand

  @impl PlayerCommand
  def execute(state, player, name) do
    name = String.trim(name)

    case validate_name(state, name) do
      :ok -> {:ok, update_name(state, player, name), nil}
      {:error, reason} -> {:error, state, reason}
    end
  end

  defp validate_name(state, name) do
    cond do
      String.length(name) > 20 -> {:error, "Name cannot exceed 20 characters"}
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
end
