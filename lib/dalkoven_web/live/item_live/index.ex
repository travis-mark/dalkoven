defmodule DalkovenWeb.ItemLive.Index do
  use DalkovenWeb, :live_view

  alias Dalkoven.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:actions>
          <.button variant="primary" navigate={~p"/items/new"}>
            <.icon name="hero-plus" /> New Item
          </.button>
        </:actions>
      </.header>

      <.table
        id="items"
        rows={@streams.items}
        row_click={fn {_id, item} -> JS.navigate(~p"/items/#{item}") end}
      >
        <:col :let={{_id, item}} label="Toggle">{item.toggle}</:col>
        <:col :let={{_id, item}} label="Label">{item.label}</:col>
        <:action :let={{_id, item}}>
          <div class="sr-only">
            <.link navigate={~p"/items/#{item}"}>Show</.link>
          </div>
          <.link navigate={~p"/items/#{item}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, item}}>
          <.link
            phx-click={JS.push("delete", value: %{id: item.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Todo.subscribe_items(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Todos")
     |> stream(:items, Todo.list_items(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Todo.get_item!(socket.assigns.current_scope, id)
    {:ok, _} = Todo.delete_item(socket.assigns.current_scope, item)

    {:noreply, stream_delete(socket, :items, item)}
  end

  @impl true
  def handle_info({type, %Dalkoven.Todo.Item{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :items, Todo.list_items(socket.assigns.current_scope), reset: true)}
  end
end
