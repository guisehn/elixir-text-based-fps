defmodule TextBasedFPSWeb.GameChannel do
  use TextBasedFPSWeb, :channel

  alias TextBasedFPS.{Game, Text}

  @impl true
  def join(_topic, _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  @impl true
  def handle_in(command, _payload, socket) do
    %{player_key: player_key} = socket.assigns
    {status, result} = Game.execute_command(player_key, command)
    {:reply, {status, %{message: result}}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    IO.puts("Player joined: #{socket.assigns.player_key}")
    player = Game.get_player(socket.assigns.player_key)
    push(socket, "welcome", %{message: welcome_message(player)})
    {:noreply, socket}
  end

  @impl true
  def terminate(reason, %{assigns: %{player_key: player_key}}) do
    IO.puts("Player left: #{player_key}, reason: #{inspect(reason)}")
    Game.remove_player(player_key)
  end

  defp welcome_message(%Game.Player{name: nil}) do
    "Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game."
  end

  defp welcome_message(%Game.Player{room: nil}) do
    "Welcome to the text-based FPS! Type #{Text.highlight("join-room <room name>")} to join the game."
  end

  defp welcome_message(%Game.Player{}) do
    "You're currently in the game. Type #{Text.highlight("look")} to see where you are in the map."
  end

  defp welcome_message(_) do
    Text.danger("It looks like the server may have crashed. 👀 Reload the page to keep playing.")
  end
end
