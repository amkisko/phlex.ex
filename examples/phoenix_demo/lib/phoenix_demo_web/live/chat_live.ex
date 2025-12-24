defmodule PhoenixDemoWeb.ChatLive do
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
     |> assign(:message, "")
     |> assign(:messages, messages)}
  end

  @impl true
  def handle_info({:new_message, message_data}, socket) do
    {:noreply, assign(socket, :messages, socket.assigns.messages ++ [message_data])}
  end

  @impl true
  def handle_event("send", %{"message" => message}, socket) when message != "" do
    alias PhoenixDemo.Schemas.Message

    # Get next ID
    max_id = Repo.aggregate(Message, :max, :id) || 0
    next_id = max_id + 1

    new_message =
      %Message{
        id: next_id,
        sender: "You",
        text: message,
        type: "sent"
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

    # Broadcast to all connected clients for real-time updates
    Phoenix.PubSub.broadcast(PhoenixDemo.PubSub, "chat", {:new_message, message_data})

    {:noreply, socket |> assign(:messages, socket.assigns.messages ++ [message_data]) |> assign(:message, "")}
  end

  def handle_event("send", _params, socket), do: {:noreply, socket}

  def handle_event("submit_survey", _params, socket), do: {:noreply, socket}

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, :message, message)}
  end

  def handle_event("update_message", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      messages: assigns.messages,
      message: assigns.message
    }
    # Return Phlex component as Phoenix.LiveView.Rendered
    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Chat.render(component_assigns)
    )
  end
end
