defmodule TextBasedFPS.CLI.Server.Messages do
  alias Mix.Tasks.Cli.Client, as: MixClient
  alias TextBasedFPS.Text

  def display_start_failed_warning do
    IO.puts(
      Text.danger("""
      Could not start node. Make sure epmd is running and there is not another server
      instance running in this machine.
      """)
    )

    IO.puts("")
  end

  def display_welcome_message(options) do
    IO.puts("Server node started: #{Node.self()}")
    IO.puts("Cookie: #{Node.get_cookie()}")

    display_connection_example(options)

    IO.puts(
      ~s(You can also type commands below to manage the server. Type "help" to see available commands.)
    )

    IO.puts("")
  end

  defp display_connection_example(%{external: true}) do
    IO.puts(
      "Connect a new player locally by running '#{MixClient.command_example(Node.self(), Node.get_cookie())}' in another terminal session."
    )
  end

  defp display_connection_example(_) do
    IO.puts(
      "Connect a new player locally by running '#{MixClient.command_example()}' in another terminal session."
    )
  end
end
