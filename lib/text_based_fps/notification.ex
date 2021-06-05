defmodule TextBasedFPS.Notification do
  @type t :: %TextBasedFPS.Notification{
    player_key: String.t,
    body: String.t,
    created_at: DateTime.t
  }

  defstruct [:player_key, :body, :created_at]

  def new(player_key, body) do
    %TextBasedFPS.Notification{
      player_key: player_key,
      body: body,
      created_at: DateTime.utc_now()
    }
  end
end
