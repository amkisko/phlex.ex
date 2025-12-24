defmodule PhoenixDemoWeb.AdminChatLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.Message

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(PhoenixDemo.PubSub, "chat")
    end

    messages =
      Repo.all(
        from m in Message,
          order_by: [asc: m.inserted_at],
          select: %{
            id: m.id,
            sender: m.sender,
            text: m.text,
            time: m.inserted_at,
            type: m.type
          }
      )
      |> Enum.map(fn msg ->
        time_str =
          msg.time
          |> DateTime.to_time()
          |> Time.to_string()
          |> String.slice(0, 5)

        %{msg | time: time_str}
      end)

    {:ok,
     socket
     |> assign(:reply_message, "")
     |> assign(:selected_message_id, nil)
     |> assign(:messages, messages)}
  end

  @impl true
  def handle_info({:new_message, message_data}, socket) do
    {:noreply, assign(socket, :messages, socket.assigns.messages ++ [message_data])}
  end

  @impl true
  def handle_event("select_message", %{"id" => id}, socket) do
    {:noreply, assign(socket, :selected_message_id, String.to_integer(id))}
  end

  @impl true
  def handle_event("reply", %{"message" => message, "to_message_id" => to_id}, socket) when message != "" do
    to_message_id = String.to_integer(to_id)
    original_message = Enum.find(socket.assigns.messages, fn m -> m.id == to_message_id end)

    # Get next ID
    max_id = Repo.aggregate(Message, :max, :id) || 0
    next_id = max_id + 1

    new_message =
      %Message{
        id: next_id,
        sender: "Admin",
        text: "Re: #{original_message.text}\n\n#{message}",
        type: "received"
      }
      |> Repo.insert!()

    time_str =
      new_message.inserted_at
      |> DateTime.to_time()
      |> Time.to_string()
      |> String.slice(0, 5)

    message_data = %{
      id: new_message.id,
      sender: new_message.sender,
      text: new_message.text,
      time: time_str,
      type: new_message.type
    }

    # Broadcast to all connected clients
    Phoenix.PubSub.broadcast(PhoenixDemo.PubSub, "chat", {:new_message, message_data})

    {:noreply, socket |> assign(:messages, socket.assigns.messages ++ [message_data]) |> assign(:reply_message, "") |> assign(:selected_message_id, nil) |> put_flash(:info, "Reply sent!")}
  end

  @impl true
  def handle_event("update_reply", %{"message" => message}, socket) do
    {:noreply, assign(socket, :reply_message, message)}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      messages: assigns.messages,
      reply_message: assigns.reply_message,
      selected_message_id: assigns.selected_message_id
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.AdminChat.render(component_assigns)
    )
  end
end
