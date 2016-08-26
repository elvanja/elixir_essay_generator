defmodule TrigramAnalyzerTest do
  use ExUnit.Case
  doctest TrigramAnalyzer

  test "returns empty for single word" do
    assert TrigramAnalyzer.analyze("single") == %{}
  end

  test "returns empty for two words" do
    assert TrigramAnalyzer.analyze("one two") == %{}
  end

  test "should analyze triplet" do
    assert TrigramAnalyzer.analyze("one two three") == %{
          {"one", "two"} => ["three"]
    }
  end

  test "should analyze four words" do
    assert TrigramAnalyzer.analyze("one two three four") == %{
          {"one", "two"} => ["three"],
          {"two", "three"} => ["four"]
    }
  end

  test "should analyze repeat" do
    assert TrigramAnalyzer.analyze("one two three one two three") == %{
          {"one", "two"} => ["three", "three"],
          {"two", "three"} => ["one"],
          {"three", "one"} => ["two"]
    }
  end

  test "should analyze kata sample data" do
    assert TrigramAnalyzer.analyze("I wish I may I wish I might") == %{
          {"I", "wish"} => ["I", "I"],
          {"wish", "I"} => ["might", "may"],
          {"I", "may"} => ["I"],
          {"may", "I"} => ["wish"]
    }
  end

  test "accepts and respects ngram size" do
    assert TrigramAnalyzer.analyze("one two three four", 2) == %{
          {"one"} => ["two"],
          {"two"} => ["three"],
          {"three"} => ["four"]
    }
  end

  test "accepts tokens for analysis" do
    assert "I wish I may I wish I might" |> String.split |> TrigramAnalyzer.analyze == %{
          {"I", "wish"} => ["I", "I"],
          {"wish", "I"} => ["might", "may"],
          {"I", "may"} => ["I"],
          {"may", "I"} => ["wish"]
    }
  end

  test "should gen freq from kata sample data" do
    assert TrigramAnalyzer.freq(TrigramAnalyzer.analyze("I wish I may I wish I might")) == %{
          {"I", "wish"} => %{"I" => 2},
          {"wish", "I"} => %{"may" => 1, "might" => 1},
          {"I", "may"} => %{"I" => 1},
          {"may", "I"} => %{"wish" => 1}
    }
  end
end
