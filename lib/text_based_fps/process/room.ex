defmodule TextBasedFPS.Process.Room do
  alias TextBasedFPS.Room, as: GameRoom

  use Agent

  @spec start_link(String.t()) :: Agent.on_start()
  def start_link(room_name) do
    Agent.start_link(
      fn -> GameRoom.new(room_name) end,
      name: get_process_reference(room_name)
    )
  end

  @doc "Gets the current state of the room with the given name"
  @spec get(String.t()) :: GameRoom.t()
  def get(room_name), do: Agent.get(get_process_reference(room_name), & &1)

  @doc """
  Executes a function from the `TextBasedFPS.Room` module on the room with the
  given name, returning the current state of the room.

  Example:
  > Room.exec("room_name", :add_random_object, {5, 5})
  """
  @spec exec(String.t(), atom, list) :: GameRoom.t()
  def exec(room_name, fun, args) do
    Agent.get_and_update(
      get_process_reference(room_name),
      fn state ->
        new_state = apply(GameRoom, fun, [state | args])
        {new_state, new_state}
      end
    )
  end

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
