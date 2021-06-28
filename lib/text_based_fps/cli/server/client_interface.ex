defmodule TextBasedFPS.CLI.Server.ClientInterface do
  alias TextBasedFPS.{Text, ServerAgent}

  def join_client(player_pid) do
    ServerAgent.add_player(player_pid)
    show_welcome_message()
    handle_command(player_pid)
  end

  defp show_welcome_message() do
    IO.puts("Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game.")
  end

  defp handle_command(player_pid) do
    command = IO.gets(IO.ANSI.reset() <> "> ") |> String.trim()
    result = ServerAgent.run_command(player_pid, command)

    case result do
      {:ok, msg} -> IO.puts(msg)
      {:error, msg} -> IO.puts(Text.danger(msg))
    end

    dispatch_notifications()
    handle_command(player_pid)
  end

  defp dispatch_notifications do
    Enum.each(ServerAgent.get_and_clear_notifications(), &dispatch_notification/1)
  end

  defp dispatch_notification(%{body: body, player_key: player_pid}) do
    send(player_pid, {:notification, body})
  end
end
