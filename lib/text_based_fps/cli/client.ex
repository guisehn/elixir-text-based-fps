defmodule TextBasedFPS.CLI.Client do
  alias TextBasedFPS.CLI

  def start do
    start_node()

    pid = Node.spawn_link(CLI.Server.node_name(), fn ->
      receive do
        pid -> CLI.Server.join_client(pid)
      end
    end)

    send pid, self()

    wait_message()
  end

  defp start_node do
    random = SecureRandom.uuid()
    node_name = generate_node_name(random)
    Node.start(node_name)
  end

  defp wait_message do
    receive do
      {:notification, notification_body} -> IO.puts(notification_body)
    end

    wait_message()
  end

  defp generate_node_name(id) do
    :"text-based-fps-client-#{id}@127.0.0.1"
  end
end
