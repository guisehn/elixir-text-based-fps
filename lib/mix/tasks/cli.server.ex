defmodule Mix.Tasks.Cli.Server do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    TextBasedFPS.ServerAgent.start_link([])
    TextBasedFPS.CLI.Server.start()
  end
end
