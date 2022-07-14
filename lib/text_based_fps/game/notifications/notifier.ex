defmodule TextBasedFPS.Game.Notifications.Notifier.Behavior do
  alias TextBasedFPS.Game.Player

  @callback notify(Player.key_t(), String.t()) :: :ok
end

defmodule TextBasedFPS.Game.Notifications.Notifier do
  @behaviour __MODULE__.Behavior

  @impl true
  def notify(player_key, msg) when is_pid(player_key) do
    send(player_key, {:notification, msg})
    :ok
  end

  @impl true
  def notify(player_key, msg) when is_binary(player_key) do
    TextBasedFPSWeb.Endpoint.broadcast("game:#{player_key}", "notification", %{message: msg})
    :ok
  end
end
