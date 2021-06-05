defmodule TextBasedFPSWeb.GameChannel do
  use TextBasedFPSWeb, :channel

  import TextBasedFPS.Text

  @impl true
  def join(_topic, _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in(command, _payload, socket) do
    %{player_key: player_key} = socket.assigns
    {status, result} = TextBasedFPS.ServerAgent.run_command(player_key, command)
    {:reply, {status, result}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    player = TextBasedFPS.ServerAgent.get_player(socket.assigns.player_key)
    push(socket, "welcome", %{message: welcome_message(player)})
    {:noreply, socket}
  end

  defp welcome_message(%{name: nil}) do
    "Welcome to the text-based FPS! Type #{highlight("set-name <your name>")} to join the game."
  end
  defp welcome_message(%{room: nil}) do
    "Welcome to the text-based FPS! Type #{highlight("join-room <room name>")} to join the game."
  end
  defp welcome_message(_) do
    "You're currently in the game. Type #{highlight("look")} to see where you are in the map."
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end
end
