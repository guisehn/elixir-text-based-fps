defmodule Mix.Tasks.Cli.Client do
  use Mix.Task

  @command "mix cli.client"

  @impl Mix.Task
  def run(args) do
    {options, _, _} =
      OptionParser.parse(args, strict: [server: :string, cookie: :string])

    Application.put_env(TextBasedFPS.Application, :boot_mode, :"cli.client", persistent: true)
    Mix.Tasks.Run.run([])

    options
    |> Enum.into(%{})
    |> TextBasedFPS.CLI.Client.start()
  end

  def command_example, do: @command

  def command_example(server, cookie) do
    "#{@command} --server #{server} --cookie #{cookie}"
  end
end
