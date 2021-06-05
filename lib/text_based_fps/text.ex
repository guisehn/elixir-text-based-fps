defmodule TextBasedFPS.Text do
  def highlight(text), do: paint(text, IO.ANSI.yellow())

  def red(text), do: paint(text, IO.ANSI.red())

  defp paint(text, color) do
    color <> String.replace(text, IO.ANSI.reset(), color) <> IO.ANSI.reset()
  end
end
