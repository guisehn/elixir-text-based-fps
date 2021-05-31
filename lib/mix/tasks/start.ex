defmodule Mix.Tasks.Start do
  use Mix.Task

  @impl Mix.Task
  def run(_), do: TextBasedFPS.CLI.start()
end
