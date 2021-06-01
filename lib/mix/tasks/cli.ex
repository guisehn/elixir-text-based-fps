defmodule Mix.Tasks.Cli do
  use Mix.Task

  @impl Mix.Task
  def run(_), do: TextBasedFPS.CLI.start()
end
