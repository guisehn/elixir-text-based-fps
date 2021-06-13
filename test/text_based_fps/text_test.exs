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

  describe "unpaint/1" do
    painted_text =
      "#{Text.paint("a", :info)} #{Text.paint("b", :success)} " <>
        "#{Text.paint("c", :danger)} #{Text.paint("d", :info)}"

    assert Text.unpaint(painted_text) == "a b c d"
  end

  describe "find_painted_text/2" do
    painted_text =
      "#{Text.paint("foo", :info)} #{Text.paint("bar", :success)} " <>
        "#{Text.paint("baz", :danger)} #{Text.paint("qux", :info)}"

    assert Text.find_painted_text(painted_text, :info) == ["foo", "qux"]
    assert Text.find_painted_text(painted_text, :success) == ["bar"]
    assert Text.find_painted_text(painted_text, :danger) == ["baz"]
    assert Text.find_painted_text("hi", :danger) == []
  end
end
