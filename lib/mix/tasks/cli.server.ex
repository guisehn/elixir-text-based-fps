defmodule Mix.Tasks.Cli.Server do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [cookie: :string])
    TextBasedFPS.ServerAgent.start_link([])
    TextBasedFPS.CLI.Server.start(options)
  end
end
