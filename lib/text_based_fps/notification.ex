defmodule TextBasedFPS.Notification do
  defstruct [:player_key, :body, :created_at]

  def new(player_key, body) do
    %TextBasedFPS.Notification{
      player_key: player_key,
      body: body,
      created_at: DateTime.utc_now()
    }
  end
end
