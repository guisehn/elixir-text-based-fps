defmodule TextBasedFPS.CLI.Server.Console do
  alias TextBasedFPS.{Text, ServerAgent}

  def start, do: handle_command()

  defp handle_command() do
    command = IO.gets(IO.ANSI.reset() <> "> ") |> String.trim()

    case command do
      "state" ->
        IO.inspect(ServerAgent.get_state())

      _ ->
        IO.puts(Text.danger("Command not found"))
    end

    handle_command()
  end
end
