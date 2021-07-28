defmodule Mix.Tasks.Cli.Client do
  use Mix.Task

  @command "mix cli.client"

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args, strict: [server_hostname: :string, cookie: :string])

    Application.put_env(TextBasedFPS.Application, :boot_mode, :"cli.client", persistent: true)
    Mix.Tasks.Run.run(args)

    TextBasedFPS.CLI.Client.start(options)
  end

  def example, do: @command

  def example(server_node, cookie) do
    [_, hostname] = server_node |> Atom.to_string() |> String.split("@")
    "#{@command} --server-hostname #{hostname} --cookie #{cookie}"
  end
end
