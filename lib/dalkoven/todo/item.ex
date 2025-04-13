defmodule Dalkoven.Todo.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :toggle, :boolean, default: false
    field :label, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs, user_scope) do
    item
    |> cast(attrs, [:toggle, :label])
    |> validate_required([:toggle, :label])
    |> put_change(:user_id, user_scope.user.id)
  end
end
