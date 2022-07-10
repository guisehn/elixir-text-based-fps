defmodule TextBasedFPS.CLI.Server do
  alias TextBasedFPS.{CLI, Game, Text}
  alias TextBasedFPS.CLI.Server.Messages

  @type options :: %{
          optional(:external) => boolean(),
          optional(:cookie) => String.t()
        }

  @node_name :"text-based-fps-server"

  @welcome "Welcome to the text-based FPS! Type #{Text.highlight("set-name <your name>")} to join the game."

  def start(options) do
    start_node(options)

    if node_started?() do
      CLI.Utils.set_cookie(options)
    else
      Messages.display_start_failed_warning()
    end

    Messages.display_welcome_message(options)

    CLI.Server.Console.start()
  end

  def node_shortname, do: @node_name

  @spec join_client(pid) :: no_return
  def join_client(player_pid) do
    Game.add_player(player_pid)
    send(player_pid, {:notification, @welcome})
    wait_client_message(player_pid)
  end

  defp start_node(%{external: true}) do
    ip_address = CLI.Utils.get_private_ipaddr()
    node_longname = :"#{@node_name}@#{ip_address}"
    Node.start(node_longname, :longnames)
  end

  defp start_node(_) do
    Node.start(@node_name, :shortnames)
  end

  defp node_started? do
    Node.self() != :nonode@nohost
  end

  defp wait_client_message(player_pid) do
    receive do
      {:command, command} ->
        result = Game.execute_command(player_pid, command)
        send(player_pid, {:reply, result})
    end

    wait_client_message(player_pid)
  end
end
