defmodule TextBasedFPS.Game.Player do
  @moduledoc """
  Represents a player on the server, which may or may not be playing in a room.

  This struct doesn't have any in-game information such as ammo, health, etc.
  That kind of info is held by %TextBasedFPS.Game.RoomPlayer{}
  """

  alias __MODULE__

  defstruct [:key, name: nil, room: nil, last_command_at: nil]

  @type t :: %Player{
          key: key_t,
          name: String.t() | nil,
          room: String.t() | nil,
          last_command_at: DateTime.t() | nil
        }

  @type key_t :: String.t() | pid()

  @name_max_length 20

  @spec new(key_t) :: t
  def new(key) do
    %Player{key: key}
  end

  @spec generate_key() :: String.t()
  def generate_key, do: SecureRandom.uuid()

  @spec touch(t) :: t
  def touch(player), do: Map.put(player, :last_command_at, DateTime.utc_now())

  @spec validate_name(String.t()) ::
          :ok
          | {:error, :empty}
          | {:error, :too_large}
          | {:error, :invalid_chars}
  def validate_name(name) do
    cond do
      name == "" -> {:error, :empty}
      String.length(name) > @name_max_length -> {:error, :too_large}
      String.match?(name, ~r/[^a-zA-Z0-9-]/) -> {:error, :invalid_chars}
      true -> :ok
    end
  end

  @spec name_max_length() :: non_neg_integer()
  def name_max_length, do: @name_max_length
end
