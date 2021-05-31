defmodule TextBasedFPS.GameMap.TextParser do
  def parse(str) do
    str
    |> String.trim_trailing
    |> String.split("\n")
    |> trim_leading_empty_lines
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.graphemes/1)
    |> equalize_line_sizes
  end

  defp trim_leading_empty_lines([line | remaining_lines]) do
    if String.trim(line) == "" do
      trim_leading_empty_lines(remaining_lines)
    else
      [line | remaining_lines]
    end
  end

  defp equalize_line_sizes(lines) do
    larger_line_size = lines |> Enum.map(&length/1) |> Enum.max
    Enum.map(lines, fn line -> complete_line(line, larger_line_size) end)
  end

  defp complete_line(line, size) do
    line ++ replicate(" ", size - length(line))
  end

  defp replicate(element, n), do: for i <- 0..n, i > 0, do: element
end
