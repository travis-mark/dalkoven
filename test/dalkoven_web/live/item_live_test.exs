defmodule DalkovenWeb.ItemLiveTest do
  use DalkovenWeb.ConnCase

  import Phoenix.LiveViewTest
  import Dalkoven.TodoFixtures

  @create_attrs %{label: "some label", toggle: true}
  @update_attrs %{label: "some updated label", toggle: false}
  @invalid_attrs %{label: nil, toggle: false}

  setup :register_and_log_in_user

  defp create_item(%{scope: scope}) do
    item = item_fixture(scope)

    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, ~p"/items")

      assert html =~ "Todos"
      assert html =~ item.label
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Item")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/new")

      assert render(form_live) =~ "New Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item-form", item: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items")

      html = render(index_live)
      assert html =~ "Item created successfully"
      assert html =~ "some label"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#items-#{item.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/#{item}/edit")

      assert render(form_live) =~ "Edit Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#item-form", item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items")

      html = render(index_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated label"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("#items-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#items-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, ~p"/items/#{item}")

      assert html =~ "Show Item"
      assert html =~ item.label
    end

    test "updates item and returns to show", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, ~p"/items/#{item}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/items/#{item}/edit?return_to=show")

      assert render(form_live) =~ "Edit Item"

      assert form_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#item-form", item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/items/#{item}")

      html = render(show_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated label"
    end
  end
end
