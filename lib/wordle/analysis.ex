defmodule Wordle.Analysis do
  @doc """
  Similar to String.to_charlist/1, but different handling for duplicate letters.

  iex> Analysis.to_keylist("unite")
  ~c"unite"
  iex> Analysis.to_keylist("these")
  [116, 104, 101, 115, "ee"]
  """
  def to_keylist(word) do
    {result, _} =
      word
      |> String.to_charlist()
      |> Enum.reduce({[], %{}}, fn char, {result, counter} ->
        case Map.get(counter, char) do
          nil ->
            {[char | result], Map.put(counter, char, 1)}

          count ->
            key = String.duplicate(<<char>>, count + 1)
            {[key | result], Map.put(counter, char, count + 1)}
        end
      end)

    Enum.reverse(result)
  end

  @doc """
  Count the frequency of each letter for analysis

  iex> ["unite", "these"] |> Analysis.count_character_frequencies
  %{101 => 2, 104 => 1, 105 => 1, 110 => 1, 115 => 1, 116 => 2, 117 => 1, "ee" => 1}
  """
  def count_character_frequencies(words) do
    words
    |> Enum.reduce(%{}, fn word, acc ->
      word
      |> to_keylist
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
    |> to_keylist
    |> Enum.reduce(0, fn char, sum -> sum + Map.get(frequencies, char, 0) end)
  end

  @doc """
  Return the highest scoring word for today's puzzle.
  """
  def guess_next_word() do
    guess_next_word(Date.utc_today())
  end

  @doc """
  Return the highest scoring word for a given date.
  """
  def guess_next_word(date) do
    allowed = Wordle.Puzzle.get_wordle_answers()
    solutions = Wordle.Puzzle.solutions_older_than(date)
    freq = count_character_frequencies(solutions)

    (allowed -- solutions)
    |> Enum.max(&(word_score(freq, &1) > word_score(freq, &2)))
  end
end
