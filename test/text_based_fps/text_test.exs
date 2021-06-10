defmodule TextBasedFPS.TextTest do
  alias TextBasedFPS.Text

  use ExUnit.Case, async: true

  describe "paint/2" do
    test "paints the text and resets to default color" do
      assert Text.paint("foo", :danger) == "\e[31mfoo\e[0m"
    end

    test "encloses painted text without resetting to default color when enclosed painted text ends" do
      input = "foo #{Text.highlight("look at me")} bar"
      output = "\e[31mfoo \e[33mlook at me\e[31m bar\e[0m"
      assert Text.paint(input, :danger) == output
    end
  end
end
