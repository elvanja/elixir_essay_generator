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
    tokens
    |> to_ngrams(ngram_size)
    |> to_ngram_tuples
    |> reduce_occurances
  end

  defp to_ngrams(tokens, ngram_size) do
    tokens |> Stream.chunk(ngram_size, 1)
  end

  defp to_ngram_tuples(ngrams) do
    ngrams |> Stream.map(&(to_ngram_tuple(&1)))
  end

  defp to_ngram_tuple(ngram) do
    source = Enum.drop(ngram, -1) |> List.to_tuple
    follower = List.last(ngram)
    {source, follower}
  end

  defp reduce_occurances(ngram_tuples) do
    ngram_tuples |> Enum.reduce(%{}, &(update_occurence(&1, &2)))
  end

  defp update_occurence({source, follower}, acc) do
    acc |> Map.update(source, [follower], &(Enum.reverse([follower | &1])))
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
