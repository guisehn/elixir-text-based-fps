defmodule TextBasedFPS.GameState.RoomSupervisor do
  @moduledoc "A dynamic supervisor for all the server rooms"

  alias TextBasedFPS.GameState.Room

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: process_ref())
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_room(opts) do
    case Room.whereis(opts[:name]) do
      :undefined -> do_add_room(opts)
      pid -> {:ok, pid}
    end
  end

  defp do_add_room(opts) do
    opts = Keyword.put(opts, :process_reference, Room.get_process_reference(opts[:name]))
    DynamicSupervisor.start_child(process_ref(), {Room, opts})
  end

  def remove_room(room_name) do
    case Room.whereis(room_name) do
      :undefined -> :ok
      pid -> DynamicSupervisor.terminate_child(process_ref(), pid)
    end
  end

  @spec get_rooms() :: list(Room.t())
  def get_rooms do
    DynamicSupervisor.which_children(process_ref())
    |> Stream.map(fn {_, pid, _, _} -> pid end)
    |> Stream.filter(&is_pid/1)
    |> Enum.map(&Room.get_room/1)
  end

  def count_rooms, do: DynamicSupervisor.count_children(process_ref()).specs

  defp process_ref, do: Process.get(__MODULE__, __MODULE__)

  def setup_local_process_ref,
    do: Process.put(__MODULE__, :"#{__MODULE__}_#{inspect(self())}")
end
