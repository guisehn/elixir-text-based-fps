defmodule TextBasedFPSWeb.GameChannel do
  use TextBasedFPSWeb, :channel

  @impl true
  def join(topic, _payload, socket) do
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in(command, payload, socket) do
    %{player_key: player_key} = socket.assigns
    {status, result} = TextBasedFPS.ServerAgent.run_command(player_key, command)
    {:reply, {status, result}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end
end
