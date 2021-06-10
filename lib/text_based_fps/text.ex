defmodule TextBasedFPS.Text do
  @type color_t :: :success | :info | :danger

  @spec highlight(String.t) :: String.t
  def highlight(text), do: paint(text, :info)

  @spec danger(String.t) :: String.t
  def danger(text), do: paint(text, :danger)

  @spec success(String.t) :: String.t
  def success(text), do: paint(text, :success)

  @spec paint(String.t, color_t) :: String.t
  def paint(text, color) do
    ansi_color = ansi_color(color)
    ansi_color <> String.replace(text, IO.ANSI.reset(), ansi_color) <> IO.ANSI.reset()
  end

  defp ansi_color(:success), do: IO.ANSI.green()
  defp ansi_color(:info), do: IO.ANSI.yellow()
  defp ansi_color(:danger), do: IO.ANSI.red()
end
