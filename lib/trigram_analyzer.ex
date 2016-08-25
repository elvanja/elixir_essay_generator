defmodule TrigramAnalyzer do
  @doc ~S"""
  Analyses the given `text` or `tokens`
  and produces a map of n-1 grams and the occurrences of their last tokens / followers

  ## Examples

      iex> TrigramAnalyzer.analyze("the quick red fox jumps over the quick hunting dog")
      %{
          {"fox", "jumps"} => ["over"],
          {"jumps", "over"} => ["the"],
          {"over", "the"} => ["quick"],
          {"quick", "hunting"} => ["dog"],
          {"quick", "red"} => ["fox"],
          {"red", "fox"} => ["jumps"],
          {"the", "quick"} => ["red", "hunting"]
      }

      iex> "the quick red fox jumps over the quick hunting dog" |> String.split |> TrigramAnalyzer.analyze
      %{
          {"fox", "jumps"} => ["over"],
          {"jumps", "over"} => ["the"],
          {"over", "the"} => ["quick"],
          {"quick", "hunting"} => ["dog"],
          {"quick", "red"} => ["fox"],
          {"red", "fox"} => ["jumps"],
          {"the", "quick"} => ["red", "hunting"]
      }
  """
  def analyze(text_or_tokens, ngram_size \\ 3)
  def analyze(text, ngram_size) when is_binary(text) do
    text
    |> String.split
    |> analyze(ngram_size)
  end
  def analyze(tokens, ngram_size) do
    count(tokens, ngram_size, %{})
  end

  defp count(tokens, ngram_size, acc) when length(tokens) < ngram_size do acc end
  defp count(tokens, ngram_size, acc) do
    count(Enum.drop(tokens, 1), ngram_size, store(acc, extract_ngram(tokens, ngram_size)))
  end

  defp store(acc, {source, follower}) do
    Map.update(acc, source, [follower], &(Enum.reverse([follower | &1])))
  end

  defp extract_ngram(tokens, ngram_size) do
    ngram = Enum.take(tokens, ngram_size)
    source = Enum.drop(ngram, -1) |> List.to_tuple
    follower = List.last(ngram)
    {source, follower}
  end

  @doc ~S"""
  Takes an `analysis` and converts it's followers list to a frequency map

  ## Examples

      iex> TrigramAnalyzer.analyze("the quick red fox jumps over the quick hunting dog") |> TrigramAnalyzer.freq
      %{
          {"fox", "jumps"} => %{"over" => 1},
          {"jumps", "over"} => %{"the" => 1},
          {"over", "the"} => %{"quick" => 1},
          {"quick", "hunting"} => %{"dog" => 1},
          {"quick", "red"} => %{"fox" => 1},
          {"red", "fox"} => %{"jumps" => 1},
          {"the", "quick"} => %{"hunting" => 1, "red" => 1}
      }
  """
  def freq(analysis) do
    analysis
    |> Enum.map(fn({source, followers}) ->
      {source, followers |> group_by_token |> count_grouped |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end

  defp group_by_token(tokens) do
    Enum.group_by(tokens, fn(token) -> token end)
  end

  defp count_grouped(tokens) do
    Enum.map(tokens, fn({token, list}) -> {token, length(list)} end)
  end


  @doc ~S"""
  Analyses the given file
  """
  def analyze_file(file, ngram_size \\ 3) do
    File.read!(file)
    |> analyze(ngram_size)
  end
end
