defmodule Mix.Tasks.Cli.Client do
  use Mix.Task

  @impl Mix.Task
  def run(_), do: TextBasedFPS.CLI.Client.start()
end
