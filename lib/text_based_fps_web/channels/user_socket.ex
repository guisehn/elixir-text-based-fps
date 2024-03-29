defmodule TextBasedFPSWeb.UserSocket do
  use Phoenix.Socket

  alias TextBasedFPS.GameState

  ## Channels
  # channel "room:*", TextBasedFPSWeb.RoomChannel
  channel "game:*", TextBasedFPSWeb.GameChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"key" => player_key}, socket, _connect_info) do
    GameState.add_player(player_key)
    {:ok, assign(socket, :player_key, player_key)}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TextBasedFPSWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.player_key}"
end
