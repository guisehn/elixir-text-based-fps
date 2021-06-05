defmodule TextBasedFPS.Text do
  @spec highlight(String.t) :: String.t
  def highlight(text), do: paint(text, IO.ANSI.yellow())

  @spec red(String.t) :: String.t
  def red(text), do: paint(text, IO.ANSI.red())

  defp paint(text, color) do
    color <> String.replace(text, IO.ANSI.reset(), color) <> IO.ANSI.reset()
  end
end
