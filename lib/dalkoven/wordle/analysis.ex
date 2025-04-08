defmodule Dalkoven.Wordle.Analysis do
  import Ecto.Query

  @doc """
  Get a list of Wordle solutions older than date.

  Used to keep statistical analysis or guessing from seeing today's answer.
  """
  def solutions_older_than(date_string) do
    query =
      from p in Dalkoven.Wordle.Puzzle,
        where: p.print_date < ^date_string,
        select: p.solution

    query |> Dalkoven.Repo.all()
  end

  @doc """
  Count the frequency of each letter for analysis

  iex(8)> ["unite", "these"] |> Analysis.count_character_frequencies
  %{101 => 3, 104 => 1, 105 => 1, 110 => 1, 115 => 1, 116 => 2, 117 => 1}
  """
  def count_character_frequencies(words) do
    words
    |> Enum.reduce(%{}, fn word, acc ->
      word
      |> String.to_charlist()
      |> Enum.reduce(acc, fn char, acc ->
        Map.update(acc, char, 1, &(&1 + 1))
      end)
    end)
  end

  def word_score(frequencies, word) do
    word
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, sum -> sum + frequencies[char] end)
  end
end
