defmodule EssayGeneratorTest do
  use ExUnit.Case
  doctest EssayGenerator

  @analysis %{
        {"I", "wish"} => ["I", "I"],
        {"wish", "I"} => ["may", "might"],
        {"I", "may"} => ["I"],
        {"may", "I"} => ["wish"]
  }

  test "generates using custom follower policy" do
    assert EssayGenerator.generate(
        @analysis,
        10,
        fn(followers) -> List.last(followers) end,
        {"I", "wish"}
    ) == "I wish I might"
  end

  test "respects the limit" do
    assert EssayGenerator.generate(
        @analysis,
        10,
        fn(followers) -> hd(followers) end,
        {"I", "wish"}
    ) == "I wish I may I wish I may I wish"
  end

  test "defaults to random policies" do
    assert EssayGenerator.generate(@analysis, 10) |> String.split(" ") |> length <= 10
  end
end
