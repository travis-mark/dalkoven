defmodule Dalkoven.Repo.Migrations.CreateWordlePuzzles do
  use Ecto.Migration

  def change do
    create table(:wordle_puzzles, primary_key: false) do
      add :id, :integer, primary_key: true
      add :days_since_launch, :integer
      add :editor, :string
      add :print_date, :string
      add :solution, :string
    end
  end
end
