defmodule Dalkoven.Wordle.Puzzle do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: false}
  schema "wordle_puzzles" do
    field :days_since_launch, :integer
    field :editor, :string
    field :print_date, :string
    field :solution, :string
  end

  @doc false
  def changeset(puzzle, attrs) do
    puzzle
    |> cast(attrs, [:days_since_launch, :editor, :id, :print_date, :solution])
    |> validate_required([:days_since_launch, :editor, :id, :print_date, :solution])
  end
end
