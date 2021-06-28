defmodule TextBasedFPS.CLI.Server do
  use Agent

  alias TextBasedFPS.{CLI, ServerAgent, Text}

  @node_name :"text-based-fps-server@0.0.0.0"
  @welcome "Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game."

  def start do
    Node.start(@node_name)

    IO.puts("Server started: #{@node_name}")
    IO.puts("Cookie: #{Node.get_cookie()}")
    IO.puts("You can now connect new clients by running 'mix cli.client'")
    IO.puts("You can also run commands below to manage the server:")
    IO.puts("")

    CLI.Server.Console.start()
  end

  def join_client(player_pid) do
    ServerAgent.add_player(player_pid)
    send(player_pid, {:notification, @welcome})
    wait_client_message(player_pid)
  end

  defp wait_client_message(player_pid) do
    receive do
      {:command, command} ->
        result = ServerAgent.run_command(player_pid, command)
        send(player_pid, {:reply, result})
        dispatch_notifications()
    end

    wait_client_message(player_pid)
  end

  defp dispatch_notifications do
    Enum.each(ServerAgent.get_and_clear_notifications(), &dispatch_notification/1)
  end

  defp dispatch_notification(%{body: body, player_key: player_pid}) do
    send(player_pid, {:notification, body})
  end

  def node_name, do: @node_name
end
