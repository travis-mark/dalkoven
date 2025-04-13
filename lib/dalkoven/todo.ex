defmodule Dalkoven.Todo do
  @moduledoc """
  The Todo context.
  """

  import Ecto.Query, warn: false
  alias Dalkoven.Repo

  alias Dalkoven.Todo.Item
  alias Dalkoven.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any item changes.

  The broadcasted messages match the pattern:

    * {:created, %Item{}}
    * {:updated, %Item{}}
    * {:deleted, %Item{}}

  """
  def subscribe_items(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Dalkoven.PubSub, "user:#{key}:items")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Dalkoven.PubSub, "user:#{key}:items", message)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items(scope)
      [%Item{}, ...]

  """
  def list_items(%Scope{} = scope) do
    Repo.all(from item in Item, where: item.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(%Scope{} = scope, id) do
    Repo.get_by!(Item, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, item = %Item{}} <-
           %Item{}
           |> Item.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, item})
      {:ok, item}
    end
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Scope{} = scope, %Item{} = item, attrs) do
    true = item.user_id == scope.user.id

    with {:ok, item = %Item{}} <-
           item
           |> Item.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, item})
      {:ok, item}
    end
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Scope{} = scope, %Item{} = item) do
    true = item.user_id == scope.user.id

    with {:ok, item = %Item{}} <-
           Repo.delete(item) do
      broadcast(scope, {:deleted, item})
      {:ok, item}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Scope{} = scope, %Item{} = item, attrs \\ %{}) do
    true = item.user_id == scope.user.id

    Item.changeset(item, attrs, scope)
  end
end
