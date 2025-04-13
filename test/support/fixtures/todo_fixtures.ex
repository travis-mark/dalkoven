defmodule Dalkoven.TodoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dalkoven.Todo` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        label: "some label",
        toggle: true
      })

    {:ok, item} = Dalkoven.Todo.create_item(scope, attrs)
    item
  end
end
