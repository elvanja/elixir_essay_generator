defmodule EssayGenerator do
  def generate(analysis, limit \\ 1000) do
    generate(analysis, limit, &random_follower_policy/1, random_key(analysis))
  end
  def generate(analysis, limit, follower_policy, start_from) do
    doGenerate(analysis, follower_policy, start_from, Tuple.to_list(start_from) |> Enum.reverse, limit)
    |> Enum.reverse
    |> Enum.join(" ")
  end

  defp doGenerate(_, _, _, acc, limit) when length(acc) >= limit do acc end
  defp doGenerate(analysis, follower_policy, source, acc, limit) do
    followers = Map.get(analysis, source)
    case followers do
      nil ->
        acc
      _ ->
        next_follower = follower_policy.(followers)
        next_source = source |> Tuple.delete_at(0) |> Tuple.append(next_follower)
        doGenerate(analysis, follower_policy, next_source, [next_follower | acc], limit)
    end
  end

  defp random_follower_policy(followers) do
    followers |> Enum.random
  end

  defp random_key(map) do
    map |> Map.keys |> Enum.random
  end
end
