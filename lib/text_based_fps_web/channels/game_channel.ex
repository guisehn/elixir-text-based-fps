defmodule TextBasedFPSWeb.GameChannel do
  alias TextBasedFPSWeb.Endpoint
  alias TextBasedFPS.ServerAgent
  alias TextBasedFPS.Text

  use TextBasedFPSWeb, :channel

  @impl true
  def join(_topic, _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_in(command, _payload, socket) do
    %{player_key: player_key} = socket.assigns
    {status, result} = ServerAgent.run_command(player_key, command)

    # The action just performed might have generated notifications for other players.
    # We call dispatch_notifications/0 to deliver the newly created notifications
    # to those players.
    dispatch_notifications()

    {:reply, {status, %{message: result}}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    IO.puts("Player joined: #{socket.assigns.player_key}")
    player = ServerAgent.get_player(socket.assigns.player_key)
    push(socket, "welcome", %{message: welcome_message(player)})
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, %{assigns: %{player_key: player_key}}) do
    IO.puts("Player left: #{player_key}, reason: #{inspect(reason)}")
    ServerAgent.remove_player(player_key)
  end

  defp welcome_message(%{name: nil}) do
    "Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game."
  end
  defp welcome_message(%{room: nil}) do
    "Welcome to the text-based FPS! Type #{Text.highlight("join-room <room name>")} to join the game."
  end
  defp welcome_message(_) do
    "You're currently in the game. Type #{Text.highlight("look")} to see where you are in the map."
  end

  defp dispatch_notifications do
    Enum.each(ServerAgent.get_and_clear_notifications(), &dispatch_notification/1)
  end
  defp dispatch_notification(%{body: body, player_key: player_key}) do
    Endpoint.broadcast("game:#{player_key}", "notification", %{message: body})
  end
end
