defmodule Dalkoven.TodoTest do
  use Dalkoven.DataCase

  alias Dalkoven.Todo

  describe "items" do
    alias Dalkoven.Todo.Item

    import Dalkoven.AccountsFixtures, only: [user_scope_fixture: 0]
    import Dalkoven.TodoFixtures

    @invalid_attrs %{label: nil, toggle: nil}

    test "list_items/1 returns all scoped items" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      other_item = item_fixture(other_scope)
      assert Todo.list_items(scope) == [item]
      assert Todo.list_items(other_scope) == [other_item]
    end

    test "get_item!/2 returns the item with given id" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      other_scope = user_scope_fixture()
      assert Todo.get_item!(scope, item.id) == item
      assert_raise Ecto.NoResultsError, fn -> Todo.get_item!(other_scope, item.id) end
    end

    test "create_item/2 with valid data creates a item" do
      valid_attrs = %{label: "some label", toggle: true}
      scope = user_scope_fixture()

      assert {:ok, %Item{} = item} = Todo.create_item(scope, valid_attrs)
      assert item.label == "some label"
      assert item.toggle == true
      assert item.user_id == scope.user.id
    end

    test "create_item/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Todo.create_item(scope, @invalid_attrs)
    end

    test "update_item/3 with valid data updates the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      update_attrs = %{label: "some updated label", toggle: false}

      assert {:ok, %Item{} = item} = Todo.update_item(scope, item, update_attrs)
      assert item.label == "some updated label"
      assert item.toggle == false
    end

    test "update_item/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)

      assert_raise MatchError, fn ->
        Todo.update_item(other_scope, item, %{})
      end
    end

    test "update_item/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Todo.update_item(scope, item, @invalid_attrs)
      assert item == Todo.get_item!(scope, item.id)
    end

    test "delete_item/2 deletes the item" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert {:ok, %Item{}} = Todo.delete_item(scope, item)
      assert_raise Ecto.NoResultsError, fn -> Todo.get_item!(scope, item.id) end
    end

    test "delete_item/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      item = item_fixture(scope)
      assert_raise MatchError, fn -> Todo.delete_item(other_scope, item) end
    end

    test "change_item/2 returns a item changeset" do
      scope = user_scope_fixture()
      item = item_fixture(scope)
      assert %Ecto.Changeset{} = Todo.change_item(scope, item)
    end
  end
end
