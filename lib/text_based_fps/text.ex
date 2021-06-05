defmodule TextBasedFPS.Text do
  def highlight(text) do
    IO.ANSI.yellow() <> text <> IO.ANSI.reset()
  end
end
