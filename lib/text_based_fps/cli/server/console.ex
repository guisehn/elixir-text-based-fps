defmodule TextBasedFPS.CLI.Server.Console do
  alias TextBasedFPS.Text

  # TODO: re-introduce a way to see the server state
  @help %{}

  def start, do: handle_command()

  defp handle_command() do
    (IO.ANSI.reset() <> "> ")
    |> IO.gets()
    |> String.trim()
    |> command()

    handle_command()
  end

  defp command("help") do
    IO.puts("Commands:")
    Enum.each(@help, fn {command, description} -> IO.puts("- #{command}: #{description}") end)
    IO.puts("")
  end

  defp command(""), do: nil

  defp command(_),
    do: IO.puts(Text.danger(~s(Command not found. Type "help" to see the available commands.)))
end
