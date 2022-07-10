defmodule TextBasedFPS.Process.RoomSupervisor do
  alias TextBasedFPS.Process.Room

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_room(room_name) do
    case Room.whereis(room_name) do
      :undefined -> do_add_room(room_name)
      pid -> {:ok, pid}
    end
  end

  def remove_room(room_name) do
    case Room.whereis(room_name) do
      :undefined -> :ok
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  defp do_add_room(room_name),
    do: DynamicSupervisor.start_child(__MODULE__, {Room, room_name})
end
