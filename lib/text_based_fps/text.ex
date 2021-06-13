defmodule TextBasedFPS.Text do
  @type color_t :: :success | :info | :danger

  @spec all_colors() :: list(color_t)
  def all_colors, do: [:success, :info, :danger]

  @spec highlight(String.t()) :: String.t()
  def highlight(text), do: paint(text, :info)

  @spec danger(String.t()) :: String.t()
  def danger(text), do: paint(text, :danger)

  @spec success(String.t()) :: String.t()
  def success(text), do: paint(text, :success)

  @spec paint(String.t(), color_t) :: String.t()
  def paint(text, color) do
    ansi_color = ansi_color(color)
    ansi_color <> String.replace(text, IO.ANSI.reset(), ansi_color) <> IO.ANSI.reset()
  end

  @spec unpaint(String.t()) :: String.t()
  def unpaint(text) do
    Enum.reduce(
      all_colors(),
      text,
      fn color, text -> String.replace(text, ansi_color(color), "") end
    )
    |> String.replace(IO.ANSI.reset(), "")
  end

  @spec find_painted_text(String.t(), color_t) :: any
  def find_painted_text(text, color) do
    escaped_ansi_color = Regex.escape(ansi_color(color))
    escaped_reset = Regex.escape(IO.ANSI.reset())
    regex = Regex.compile!("#{escaped_ansi_color}([^\e]+)#{escaped_reset}")

    Regex.scan(regex, text) |> Enum.map(&Enum.at(&1, 1))
  end

  defp ansi_color(:success), do: IO.ANSI.green()
  defp ansi_color(:info), do: IO.ANSI.yellow()
  defp ansi_color(:danger), do: IO.ANSI.red()
end
