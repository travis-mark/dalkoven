defmodule DalkovenWeb.ItemLive.Form do
  use DalkovenWeb, :live_view

  alias Dalkoven.Todo
  alias Dalkoven.Todo.Item

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage item records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="item-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:toggle]} type="checkbox" label="Toggle" />
        <.input field={@form[:label]} type="text" label="Label" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Item</.button>
          <.button navigate={return_path(@current_scope, @return_to, @item)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    item = Todo.get_item!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Todo.change_item(socket.assigns.current_scope, item)))
  end

  defp apply_action(socket, :new, _params) do
    item = %Item{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, item)
    |> assign(:form, to_form(Todo.change_item(socket.assigns.current_scope, item)))
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset = Todo.change_item(socket.assigns.current_scope, socket.assigns.item, item_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.live_action, item_params)
  end

  defp save_item(socket, :edit, item_params) do
    case Todo.update_item(socket.assigns.current_scope, socket.assigns.item, item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, item)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_item(socket, :new, item_params) do
    case Todo.create_item(socket.assigns.current_scope, item_params) do
      {:ok, item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Item created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, item)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _item), do: ~p"/items"
  defp return_path(_scope, "show", item), do: ~p"/items/#{item}"
end
