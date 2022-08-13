defmodule TextBasedFPS.Game.Command.Help do
  alias TextBasedFPS.Game.Command
  alias TextBasedFPS.Text

  @behaviour Command

  @impl true
  def description, do: "Show all commands"

  @impl true
  def execute(_, _) do
    result =
      TextBasedFPS.Game.CommandList.all()
      |> Enum.map(&format_command/1)
      |> Enum.join("\n")

    {:ok, result}
  end

  defp format_command({command_name, command}) do
    Text.highlight("#{command_name}#{command_arg_example(command)}") <>
      ": #{command.description()}"
  end

  def command_arg_example(command) do
    if function_exported?(command, :arg_example, 0) do
      " <" <> command.arg_example() <> ">"
    end
  end
end
