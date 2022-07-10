defmodule TextBasedFPS.Process.Room do
  @moduledoc "An agent that represents a room of the server"

  alias TextBasedFPS.Game

  use Agent

  @spec start_link(Keyword.t()) :: Agent.on_start()
  def start_link(opts) do
    Agent.start_link(
      fn -> Game.Room.new(opts[:name], opts[:first_player_key]) end,
      name: get_process_reference(opts[:name])
    )
  end

  @doc "Gets the current state of the room with the given name or PID"
  @spec get(String.t() | pid) :: Game.Room.t()
  def get(pid) when is_pid(pid), do: Agent.get(pid, & &1)
  def get(room_name), do: Agent.get(get_process_reference(room_name), & &1)

  @doc "Updates the room with the given name using the function passed"
  @spec update(String.t(), (Room.t() -> Room.t())) :: Room.t() | nil
  def update(room_name, fun) do
    get_process_reference(room_name)
    |> Agent.get_and_update(fn room ->
      room = fun.(room)
      {room, room}
    end)
  end

  def get_and_update(room_name, fun) do
    get_process_reference(room_name) |> Agent.get_and_update(fun)
  end

  def exists?(room_name), do: whereis(room_name) != :undefined

  @doc """
  Returns PID of the room with the given name, or :undefined if it doesn't exist.
  """
  @spec whereis(String.t()) :: pid() | :undefined
  def whereis(room_name), do: room_name |> get_process_name() |> :global.whereis_name()

  @spec get_process_name(String.t()) :: String.t()
  defp get_process_name(room_name), do: "room_" <> room_name

  @spec get_process_reference(String.t()) :: {:global, String.t()}
  defp get_process_reference(room_name), do: {:global, get_process_name(room_name)}
end
