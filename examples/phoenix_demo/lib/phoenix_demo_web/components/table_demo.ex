defmodule PhoenixDemoWeb.Components.TableDemo do
  use Phlex.HTML

  def view_template(_assigns, state) do
    table(state, [class: "table-demo"], fn state ->
      state
      |> thead([], fn state ->
        tr(state, [], fn state ->
          state
          |> th([], "Name")
          |> th([], "Email")
          |> th([], "Role")
        end)
      end)
      |> tbody([], fn state ->
        state
        |> tr([], fn state ->
          state
          |> td([], "Alice")
          |> td([], "alice@example.com")
          |> td([], "Admin")
        end)
        |> tr([], fn state ->
          state
          |> td([], "Bob")
          |> td([], "bob@example.com")
          |> td([], "User")
        end)
        |> tr([], fn state ->
          state
          |> td([], "Charlie")
          |> td([], "charlie@example.com")
          |> td([], "Moderator")
        end)
      end)
    end)
  end
end

