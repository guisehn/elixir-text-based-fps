Mox.defmock(TextBasedFPS.Game.Notifications.Notifier.Mock,
  for: TextBasedFPS.Game.Notifications.Notifier.Behavior
)

Application.put_env(:text_based_fps, :notifier, TextBasedFPS.Game.Notifications.Notifier.Mock)

ExUnit.start()
