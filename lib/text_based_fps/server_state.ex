defmodule TextBasedFPS.ServerState do
  alias TextBasedFPS.ServerState
  alias TextBasedFPS.Player

  defstruct [:rooms, :players]

  def new do
    %ServerState{players: %{}, rooms: %{}}
  end

  def add_player(state) do
    player = Player.new()
    updated_players = Map.put(state.players, player.key, player)
    updated_state = Map.put(state, :players, updated_players)
    {player.key, updated_state}
  end

  def update_room(state, room_name, fun) when is_function(fun) do
    room = state.rooms[room_name]
    updated_room = fun.(room)
    updated_rooms = Map.put(state.rooms, room_name, updated_room)
    Map.put(state, :rooms, updated_rooms)
  end
  def update_room(state, room) when is_map(room) do
    updated_rooms = Map.put(state.rooms, room.name, room)
    Map.put(state, :rooms, updated_rooms)
  end

  def update_player(state, player_key, fun) do
    player = get_player(state, player_key)
    updated_player = fun.(player)
    updated_players = Map.put(state.players, player_key, updated_player)
    Map.put(state, :players, updated_players)
  end

  def get_player(state, player_key), do: state.players[player_key]

  def get_room(state, room_name), do: state.rooms[room_name]
end

# %TextBasedFPS.GameState{
#   players: %{
#     "dskdisjdsijdsid": %TextBasedFPS.Player{
#       name: "foo",
#       room: "oi"
#     }
#   },
#   rooms: %{
#     "name of the room": %TextBasedFPS.Room{
#       map: %TextBasedFPS.GameMap{},
#       players: %{
#         "dskdisjdsijdsid": %TextBasedFPS.RoomPlayer{
#           player_key: "dskdisjdsijdsid"
#           x: ?,
#           y: ?,
#           direction: ?,
#           health: ?,
#           ammo: {5, 10},
#           kills: 5,
#           killed: 10
#         }
#       }
#     }
#   }
# }
