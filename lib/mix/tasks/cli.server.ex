defmodule Mix.Tasks.Cli.Server do
  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {options, _, _} = OptionParser.parse(args, strict: [cookie: :string])

    Application.put_env(TextBasedFPS.Application, :boot_mode, :"cli.server", persistent: true)
    Mix.Tasks.Run.run([])

    TextBasedFPS.CLI.Server.start(options)
  end
end
