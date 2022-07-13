Mox.defmock(TextBasedFPS.Process.Room.Mock, for: TextBasedFPS.Process.Room.Behavior)
Application.put_env(:text_based_fps, :room_process, TextBasedFPS.Process.Room.Mock)

Mox.defmock(TextBasedFPS.Process.Players.Mock, for: TextBasedFPS.Process.Players.Behavior)
Application.put_env(:text_based_fps, :players_process, TextBasedFPS.Process.Players.Mock)

ExUnit.start()
