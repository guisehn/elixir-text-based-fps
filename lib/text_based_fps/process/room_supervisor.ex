defmodule TextBasedFPS.Process.RoomSupervisor do
  @moduledoc "A dynamic supervisor for all the server rooms"

  alias TextBasedFPS.Process.Room

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
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

  defp do_add_room(opts),
    do: DynamicSupervisor.start_child(__MODULE__, {Room, opts})

  def remove_room(room_name) do
    case Room.whereis(room_name) do
      :undefined -> :ok
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
  end

  @spec get_rooms() :: list(Room.t())
  def get_rooms do
    DynamicSupervisor.which_children(__MODULE__)
    |> Stream.map(fn {_, pid, _, _} -> pid end)
    |> Stream.filter(&is_pid/1)
    |> Enum.map(&Room.get/1)
  end

  def count_rooms, do: DynamicSupervisor.count_children(__MODULE__).specs
end
