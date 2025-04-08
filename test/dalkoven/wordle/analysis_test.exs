defmodule WordleAnalysisTest do
  use ExUnit.Case
  alias Dalkoven.Wordle.Analysis
  doctest Dalkoven.Wordle.Analysis

  # Snapshot as of 2025-04-08
  @wordle_character_frequencies %{
    97 => 398,
    98 => 101,
    99 => 193,
    100 => 146,
    101 => 508,
    102 => 82,
    103 => 108,
    104 => 159,
    105 => 242,
    106 => 13,
    107 => 82,
    108 => 272,
    109 => 111,
    110 => 240,
    111 => 280,
    112 => 129,
    113 => 12,
    114 => 346,
    115 => 250,
    116 => 276,
    117 => 163,
    118 => 65,
    119 => 70,
    120 => 17,
    121 => 137,
    122 => 15
  }

  test "Scores word" do
    assert(Analysis.word_score(@wordle_character_frequencies, "unite") == 1429)
  end
end
