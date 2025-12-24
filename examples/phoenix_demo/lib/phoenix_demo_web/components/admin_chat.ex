defmodule PhoenixDemoWeb.Components.AdminChat do
  use PhoenixDemoWeb.Components.Base, namespace: :admin

  @component_styles """
  .admin-chat-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .admin-chat-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
  }

  .admin-chat-card {
    background: #ffffff;
    border-radius: 12px;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
    padding: 2rem;
    height: 700px;
    display: flex;
    flex-direction: column;
  }

  .admin-chat-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .admin-chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    background: #f8f9fa;
    display: flex;
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .admin-message {
    display: flex;
    max-width: 85%;
  }

  .admin-message.sent {
    align-self: flex-end;
  }

  .admin-message.received {
    align-self: flex-start;
  }

  .admin-message-bubble {
    padding: 0.75rem 1rem;
    border-radius: 1rem;
    font-size: 0.9375rem;
  }

  .admin-message.sent .admin-message-bubble {
    background: #667eea;
    color: white;
  }

  .admin-message.received .admin-message-bubble {
    background: white;
    color: #1d1d1f;
    border: 1px solid #e5e7eb;
  }

  .admin-message-sender {
    font-size: 0.75rem;
    font-weight: 600;
    margin-bottom: 0.25rem;
  }

  .admin-message-text {
    margin: 0;
    white-space: pre-wrap;
  }

  .admin-message-time {
    font-size: 0.75rem;
    margin-top: 0.25rem;
    opacity: 0.7;
  }

  .admin-reply-form {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .admin-reply-textarea {
    width: 100%;
    padding: 0.875rem;
    border: 1px solid #d1d5db;
    border-radius: 0.75rem;
    font-size: 0.9375rem;
    min-height: 100px;
    resize: vertical;
  }

  .admin-reply-textarea:focus {
    outline: none;
    border-color: #667eea;
  }

  .admin-reply-button {
    padding: 0.875rem 2rem;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 0.75rem;
    font-weight: 600;
    cursor: pointer;
  }

  .admin-reply-button:hover {
    background: #5568d3;
  }

  .admin-message-selectable {
    cursor: pointer;
    transition: opacity 0.2s;
  }

  .admin-message-selectable:hover {
    opacity: 0.8;
  }

  .admin-message-selectable.selected {
    opacity: 1;
    box-shadow: 0 0 0 2px #667eea;
  }
  """

  def render_template(assigns, attrs, state) do
    messages = Map.get(assigns, :messages, [])
    reply_message = Map.get(assigns, :reply_message, "")
    selected_message_id = Map.get(assigns, :selected_message_id, nil)

    # Merge component-specific class with capsule attrs
    final_attrs = Keyword.put(attrs, :class, "admin-chat-container")

    div(state, final_attrs, fn state ->
        state
        |> div([class: "container"], fn state ->
          state
          |> div([class: "admin-chat-grid"], fn state ->
          state
          |> div([], fn state ->
            div(state, [class: "admin-chat-card"], fn state ->
              state
              |> h2([class: "admin-chat-card-title"], "All Messages")
              |> div([class: "admin-chat-messages"], fn state ->
                Enum.reduce(messages, state, fn msg, acc_state ->
                  render_message(acc_state, msg, selected_message_id)
                end)
              end)
            end)
          end)
          |> div([], fn state ->
            div(state, [class: "admin-chat-card"], fn state ->
              state
              |> h2([class: "admin-chat-card-title"], "Reply to Message")
              |> render_reply_form(reply_message, selected_message_id)
            end)
          end)
        end)
      end)
    end)
  end

  defp render_message(state, msg, selected_message_id) do
    type_class = if msg.type == "sent", do: "admin-message sent", else: "admin-message received"
    selectable_class = if msg.id == selected_message_id, do: "admin-message-selectable selected", else: "admin-message-selectable"

    div(state, [class: "#{type_class} #{selectable_class}", phx_click: "select_message", phx_value_id: msg.id], fn state ->
      div(state, [class: "admin-message-bubble"], fn state ->
        state
        |> div([class: "admin-message-sender"], msg.sender)
        |> div([class: "admin-message-text"], msg.text)
        |> div([class: "admin-message-time"], msg.time)
      end)
    end)
  end

  defp render_reply_form(state, reply_message, selected_message_id) do
    if selected_message_id do
      form(state, [class: "admin-reply-form", phx_submit: "reply"], fn state ->
        state
        |> input([type: "hidden", name: "to_message_id", value: "#{selected_message_id}"])
        |> textarea([
          name: "message",
          value: reply_message,
          phx_change: "update_reply",
          class: "admin-reply-textarea",
          placeholder: "Type your reply...",
          required: true
        ])
        |> button([type: "submit", class: "admin-reply-button"], "Send Reply")
      end)
    else
      div(state, [class: "admin-reply-form"], fn state ->
        p(state, [style: "color: #6b7280; text-align: center; padding: 2rem;"], "Select a message from the left to reply")
      end)
    end
  end
end
