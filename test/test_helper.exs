Mox.defmock(TextBasedFPS.Process.Room.Mock, for: TextBasedFPS.Process.Room.Behavior)
Application.put_env(:text_based_fps, :room_process, TextBasedFPS.Process.Room.Mock)

ExUnit.start()
