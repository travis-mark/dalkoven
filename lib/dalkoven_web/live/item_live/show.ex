defmodule DalkovenWeb.ItemLive.Show do
  use DalkovenWeb, :live_view

  alias Dalkoven.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Item {@item.id}
        <:subtitle>This is a item record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/items"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/items/#{@item}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit item
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Toggle">{@item.toggle}</:item>
        <:item title="Label">{@item.label}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Todo.subscribe_items(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Show Item")
     |> assign(:item, Todo.get_item!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Dalkoven.Todo.Item{id: id} = item},
        %{assigns: %{item: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :item, item)}
  end

  def handle_info(
        {:deleted, %Dalkoven.Todo.Item{id: id}},
        %{assigns: %{item: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current item was deleted.")
     |> push_navigate(to: ~p"/items")}
  end
end
