defmodule TextBasedFPS.CLI.Server do
  use Agent

  alias TextBasedFPS.CLI

  @node_name :"text-based-fps-server@0.0.0.0"

  defdelegate join_client(player_pid), to: TextBasedFPS.CLI.Server.ClientInterface

  def start do
    Node.start(@node_name)

    IO.puts("Server started: #{@node_name}")
    IO.puts("Cookie: #{Node.get_cookie()}")
    IO.puts("You can now connect new clients by running 'mix cli.client'")
    IO.puts("You can also run commands below to manage the server:")
    IO.puts("")

    CLI.Server.Console.start()
  end

  def node_name, do: @node_name
end
