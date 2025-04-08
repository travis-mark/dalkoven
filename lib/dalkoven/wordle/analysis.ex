defmodule Dalkoven.Wordle.Analysis do
  @doc """
  Count the frequency of each letter for analysis

  iex> ["unite", "these"] |> Analysis.count_character_frequencies
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

  @doc """
  Score a word, based on a frequency count.
  """
  def word_score(frequencies, word) do
    word
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, sum -> sum + frequencies[char] end)
  end

  def guess_next_word(date) do
    allowed = Dalkoven.Wordle.Puzzle.get_wordle_answers()
    solutions = Dalkoven.Wordle.Puzzle.solutions_older_than(date)
    freq = count_character_frequencies(solutions)

    (allowed -- solutions)
    |> Enum.max(&(word_score(freq, &1) > word_score(freq, &2)))
  end
end
