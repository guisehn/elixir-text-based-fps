defmodule TextBasedFPS.CLI.Client do
  alias TextBasedFPS.{CLI, Text}

  def start(options) do
    start_node(options)
    server_pid = join_server(options)
    Task.start(fn -> ask_command(server_pid) end)
    wait_server_message()
  end

  defp start_node(options) do
    Node.start(generate_client_node_name(), :longnames)
    CLI.Utils.maybe_set_cookie(options)
  end

  defp generate_client_node_name do
    random = SecureRandom.uuid()
    :"text-based-fps-client-#{random}@#{CLI.Utils.get_internal_ipaddr()}"
  end

  defp join_server(options) do
    server_pid =
      Node.spawn_link(server_node_name(options), fn ->
        receive do
          pid -> CLI.Server.join_client(pid)
        end
      end)

    send(server_pid, self())

    server_pid
  end

  defp ask_command(server_pid) do
    command = IO.gets(IO.ANSI.reset() <> "> ") |> String.trim()

    if command != "" do
      send(server_pid, {:command, command})
    end

    ask_command(server_pid)
  end

  defp wait_server_message do
    receive do
      message -> handle_server_message(message)
    end

    wait_server_message()
  end

  defp handle_server_message({:notification, msg}) do
    print(msg)
  end

  defp handle_server_message({:reply, result}) do
    case result do
      {:ok, msg} -> if msg != nil, do: print(msg)
      {:error, msg} -> print(Text.danger(msg))
    end
  end

  defp print(msg) do
    IO.puts(IO.ANSI.clear_line() <> IO.ANSI.cursor_left(999_999) <> IO.ANSI.reset() <> msg)
  end

  defp server_node_name(options) do
    String.to_atom("#{CLI.Server.node_shortname()}@#{server_hostname(options)}")
  end

  defp server_hostname(options) do
    if options[:server_hostname] do
      options[:server_hostname]
    else
      CLI.Utils.get_internal_ipaddr()
    end
  end
end
