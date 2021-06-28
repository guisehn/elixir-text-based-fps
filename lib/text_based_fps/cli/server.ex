defmodule TextBasedFPS.CLI.Server do
  use Agent

  alias Mix.Tasks.Cli.Client, as: MixClient
  alias TextBasedFPS.{CLI, ServerAgent, Text}

  @node_name :"text-based-fps-server"
  @welcome "Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game."

  def start(options) do
    Node.start(@node_name)
    CLI.Utils.maybe_set_cookie(options)

    IO.puts("Server node started: #{Node.self()}")
    IO.puts("Cookie: #{Node.get_cookie()}")
    IO.puts("Connect a new player locally by running '#{MixClient.example()}' in another terminal session.")
    IO.puts("If you wanna join from another computer on the same network, '#{external_connection_example()}'")
    IO.puts("You can also run commands to manage the server:")
    IO.puts("")

    CLI.Server.Console.start()
  end

  def node_name, do: @node_name

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

  defp external_connection_example do
    MixClient.example(Node.self(), Node.get_cookie())
  end
end
