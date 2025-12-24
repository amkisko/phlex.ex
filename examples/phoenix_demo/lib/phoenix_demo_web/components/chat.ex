defmodule PhoenixDemoWeb.Components.Chat do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .chat-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .chat-window {
    background: #ffffff;
    border-radius: 12px;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    overflow: hidden;
    height: 600px;
    display: flex;
    flex-direction: column;
  }

  .chat-window-header {
    background: #0071e3;
    color: white;
    padding: 1.25rem 1.5rem;
  }

  .chat-window-title {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.25rem;
  }

  .chat-window-status {
    font-size: 0.875rem;
    opacity: 0.9;
  }

  .chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 1.5rem;
    background: #f8f9fa;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .message {
    display: flex;
    max-width: 70%;
  }

  .message.sent {
    align-self: flex-end;
    justify-content: flex-end;
  }

  .message.received {
    align-self: flex-start;
    justify-content: flex-start;
  }

  .message-bubble {
    padding: 0.75rem 1rem;
    border-radius: 1rem;
    font-size: 0.9375rem;
    line-height: 1.5;
  }

  .message.sent .message-bubble {
    background: #667eea;
    color: white;
    border-bottom-right-radius: 0.25rem;
  }

  .message.received .message-bubble {
    background: white;
    color: #1d1d1f;
    border: 1px solid #e5e7eb;
    border-bottom-left-radius: 0.25rem;
  }

  .message-sender {
    font-size: 0.75rem;
    font-weight: 600;
    margin-bottom: 0.25rem;
    opacity: 0.8;
  }

  .message-text {
    margin: 0;
  }

  .message-time {
    font-size: 0.75rem;
    margin-top: 0.25rem;
    opacity: 0.7;
  }

  .chat-input-area {
    border-top: 1px solid #e5e7eb;
    padding: 1.25rem 1.5rem;
    background: white;
  }

  .chat-form {
    display: flex;
    gap: 0.75rem;
  }

  .chat-input {
    flex: 1;
    padding: 0.875rem 1rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    font-size: 15px;
    background: #ffffff;
    transition: all 0.2s ease;
  }

  .chat-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
  }

  .chat-send-button {
    padding: 0.875rem 2rem;
    background: #0071e3;
    color: white;
    border: none;
    border-radius: 8px;
    font-weight: 500;
    font-size: 15px;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .chat-send-button:hover {
    background: #0077ed;
    transform: translateY(-1px);
  }
  """

  def render_template(assigns, attrs, state) do
    messages = Map.get(assigns, :messages, [])
    message = Map.get(assigns, :message, "")

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "chat-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "chat-window"], fn state ->
          state
          |> div([class: "chat-window-header"], fn state ->
            state
            |> h2([class: "chat-window-title"], "Customer Support")
            |> p([class: "chat-window-status"], "Online now")
          end)
          |> div([class: "chat-messages"], fn state ->
            Enum.reduce(messages, state, fn msg, acc_state ->
              render_message(acc_state, msg)
            end)
          end)
          |> div([class: "chat-input-area"], fn state ->
            form(state, [class: "chat-form", phx_submit: "send", phx_change: "update_message"], fn state ->
              state
              |> input([
                type: "text",
                name: "message",
                value: message,
                class: "chat-input",
                placeholder: "Type your message...",
                autocomplete: "off"
              ])
              |> button([type: "submit", class: "chat-send-button"], "Send")
            end)
          end)
        end)
      end)
    end)
  end

  defp render_message(state, msg) do
    type_class = if msg.type == "sent", do: "message sent", else: "message received"

    div(state, [class: type_class], fn state ->
      div(state, [class: "message-bubble"], fn state ->
        state
        |> div([class: "message-sender"], msg.sender)
        |> div([class: "message-text"], msg.text)
        |> div([class: "message-time"], msg.time)
      end)
    end)
  end
end
