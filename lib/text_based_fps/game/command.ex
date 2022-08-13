defmodule TextBasedFPS.Game.Command do
  @moduledoc ~S'''
  Behaviour for implementing a game command.

  To create a command, define a module that extends this behaviour:

      defmodule TextBasedFPS.Game.Command.Example do
        @behaviour TextBasedFPS.Game.Command

        @impl true
        def execute(player, args) do
          {:ok, "Your name is <#{player.name}> and the args is #{inspect(args)}"}
        end

        @impl true
        def description, do: "Prints the player name and the args"
      end

  Then, add the command to `TextBasedFPS.Game.CommandList`, e.g.:

      @commands [
        # [...]
        {"example", Command.Example}
      ]

  When you connect to the server and write `example hello world`, you'll see:

  > Your name is <Your name> and the args is "hello world"
  '''

  alias TextBasedFPS.Game.Player

  @doc """
  The function that is going to be executed when the player runs the command.

  The first argument is the player executing the command, and the second argument
  is the arguments passed.
  When running `set-name foo`, for example, the arguments will be `foo`.
  If the user doesn't pass any arguments, `args` will be an empty string.

  The function should return an :ok or :error tuple, containing the message to be shown
  to the user. When returning an :ok tuple, the message is optional.
  """
  @callback execute(Player.t(), String.t()) :: {:ok, String.t() | nil} | {:error, String.t()}

  @doc """
  An example of argument to be passed to your command, that can be shown
  on help messages.

  This callback is optional, so you don't need to define it if your command
  doesn't take any arguments.
  """
  @callback arg_example() :: String.t()

  @doc "A description for your command, that can be shown on help messages."
  @callback description() :: String.t()

  @optional_callbacks arg_example: 0
end
