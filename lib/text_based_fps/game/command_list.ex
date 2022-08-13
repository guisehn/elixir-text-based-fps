defmodule TextBasedFPS.Game.CommandList do
  alias TextBasedFPS.Game.Command

  @commands [
    {"set-name", Command.SetName},
    {"join-room", Command.JoinRoom},
    {"room-list", Command.RoomList},
    {"look", Command.Look},
    {"move", Command.Move},
    {"turn", Command.Turn},
    {"fire", Command.Fire},
    {"ammo", Command.Ammo},
    {"reload", Command.Reload},
    {"health", Command.Health},
    {"score", Command.Score},
    {"respawn", Command.Respawn},
    {"leave-room", Command.LeaveRoom},
    {"help", Command.Help}
  ]

  def all, do: @commands
end
