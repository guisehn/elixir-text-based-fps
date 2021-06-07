defmodule TextBasedFPS.TextTest do
  alias TextBasedFPS.Text

  use ExUnit.Case, async: true

  test "highlight/1" do
    assert Text.highlight("foo") == "\e[33mfoo\e[0m"
  end

  describe "red/1" do
    test "paints the text red and resets to default color" do
      assert Text.red("foo") == "\e[31mfoo\e[0m"
    end

    test "encloses highlighted text without resetting to default color until it reaches the end" do
      input = "foo #{Text.highlight("look at me")} bar"
      output = "\e[31mfoo \e[33mlook at me\e[31m bar\e[0m"
      assert Text.red(input) == output
    end
  end
end
