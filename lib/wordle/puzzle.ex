defmodule Wordle.Puzzle do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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
    |> unique_constraint(:id)
    |> validate_required([:days_since_launch, :editor, :id, :print_date, :solution])
  end

  @doc """
  Get a list of Wordle solutions older than date.

  Used to keep statistical analysis or guessing from seeing today's answer.
  """
  def solutions_older_than(date_string) do
    query =
      from p in Wordle.Puzzle,
        where: p.print_date < ^date_string,
        select: p.solution

    query |> Dalkoven.Repo.all()
  end

  def put_wordle_answers(data) do
    binary = :erlang.term_to_binary(data)
    File.write!("priv/bin/wordle_answers.bin", binary)
  end

  def get_wordle_answers do
    binary = File.read!("priv/bin/wordle_answers.bin")
    :erlang.binary_to_term(binary)
  end
end
