defmodule TextBasedFPS.CLI.Client do
  alias TextBasedFPS.{CLI, Text}

  def start do
    start_node()
    server_pid = join_server()
    Task.start(fn -> ask_command(server_pid) end)
    wait_server_message()
  end

  defp start_node do
    node_name = SecureRandom.uuid() |> generate_node_name()
    Node.start(node_name)
  end

  defp join_server do
    server_pid =
      Node.spawn_link(CLI.Server.node_name(), fn ->
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

  defp generate_node_name(id) do
    :"text-based-fps-client-#{id}@127.0.0.1"
  end
end
