defmodule TextBasedFPS.CLI.Server.Console do
  alias TextBasedFPS.{Text, ServerAgent}

  @help %{
    "state" => "Prints the server state"
  }

  def start, do: handle_command()

  defp handle_command() do
    (IO.ANSI.reset() <> "> ")
    |> IO.gets()
    |> String.trim()
    |> command()

    handle_command()
  end

  defp command("state"), do: IO.inspect(ServerAgent.get_state())

  defp command("help") do
    IO.puts("Commands:")
    Enum.each(@help, fn {command, description} -> IO.puts("- #{command}: #{description}") end)
    IO.puts("")
  end

  defp command(""), do: nil

  defp command(_),
    do: IO.puts(Text.danger(~s(Command not found. Type "help" to see the available commands.)))
end
