defmodule PhoenixDemoWeb.Components.FormDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    form(state, [class: "form-demo"], fn state ->
      state
      |> div([class: "form-group"], fn state ->
        label(state, [for: "name"], "Name")
        |> input([type: "text", id: "name", name: "name", placeholder: "Enter your name"])
      end)
      |> div([class: "form-group"], fn state ->
        label(state, [for: "email"], "Email")
        |> input([type: "email", id: "email", name: "email", placeholder: "Enter your email"])
      end)
      |> div([class: "form-group"], fn state ->
        label(state, [for: "message"], "Message")
        |> textarea([id: "message", name: "message", rows: "4", placeholder: "Enter your message"], "")
      end)
      |> div([class: "form-group"], fn state ->
        label(state, [for: "country"], "Country")
        |> select([id: "country", name: "country"], fn state ->
          state
          |> option([value: ""], "Select a country")
          |> option([value: "us"], "United States")
          |> option([value: "uk"], "United Kingdom")
          |> option([value: "ca"], "Canada")
        end)
      end)
      |> button([type: "submit", class: "button-demo"], "Submit")
    end)
  end
end

