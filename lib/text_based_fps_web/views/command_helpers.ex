defmodule TextBasedFPSWeb.CommandHelpers do
  def command_arg_example(command) do
    if function_exported?(command, :arg_example, 0) do
      Phoenix.HTML.raw(" &lt;" <> command.arg_example() <> "&gt;")
    end
  end
end
