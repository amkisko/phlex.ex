defmodule PhoenixDemoWeb.Components.Todos do
  use PhoenixDemoWeb.Components.Base

  @component_styles """
  .todos-container {
    min-height: 100vh;
    background: #fbfbfd;
    padding: 3rem 0;
  }

  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
  }

  .todos-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 2rem;
  }

  .todos-card {
    background: #ffffff;
    border-radius: 12px;
    padding: 2rem;
    border: 0.5px solid rgba(0, 0, 0, 0.1);
  }

  .todos-card-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .todos-form {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    margin-bottom: 1.5rem;
  }

  .todos-form-row {
    display: flex;
    gap: 0.75rem;
  }

  .todos-input {
    flex: 1;
    padding: 0.875rem 1rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    font-size: 15px;
    background: #ffffff;
    transition: all 0.2s ease;
  }

  .todos-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 3px rgba(0, 113, 227, 0.1);
  }

  .todos-add-button {
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

  .todos-add-button:hover {
    background: #0077ed;
    transform: translateY(-1px);
  }

  .todos-options {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
    padding: 0.75rem;
    background: #f9fafb;
    border-radius: 8px;
    margin-top: 0.5rem;
  }

  .todos-option-group {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    flex: 1;
    min-width: 120px;
  }

  .todos-option-label {
    font-size: 0.75rem;
    font-weight: 500;
    color: #6b7280;
  }

  .todos-option-input {
    padding: 0.5rem;
    border: 0.5px solid rgba(0, 0, 0, 0.2);
    border-radius: 6px;
    font-size: 14px;
  }

  .todos-recurring-toggle {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
    padding: 0.5rem;
    border-radius: 6px;
    transition: background 0.2s;
  }

  .todos-recurring-toggle:hover {
    background: #f3f4f6;
  }

  .todos-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .todos-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    border: 1px solid #e5e7eb;
    border-radius: 0.75rem;
    transition: background 0.2s;
  }

  .todos-item:hover {
    background: #f9fafb;
  }

  .todos-checkbox {
    width: 1.25rem;
    height: 1.25rem;
    cursor: pointer;
  }

  .todos-label {
    flex: 1;
    cursor: pointer;
    font-size: 0.9375rem;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .todos-label.completed {
    text-decoration: line-through;
    color: #9ca3af;
  }

  .todos-label-title {
    font-weight: 500;
  }

  .todos-label-meta {
    font-size: 0.75rem;
    color: #6b7280;
    display: flex;
    gap: 0.5rem;
    align-items: center;
  }

  .todos-priority {
    padding: 0.25rem 0.75rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 500;
  }

  .todos-priority.high {
    background: #fee2e2;
    color: #991b1b;
  }

  .todos-priority.medium {
    background: #fef3c7;
    color: #92400e;
  }

  .todos-priority.low {
    background: #d1fae5;
    color: #065f46;
  }

  .todos-recurring-badge {
    padding: 0.125rem 0.5rem;
    border-radius: 9999px;
    font-size: 0.625rem;
    font-weight: 600;
    background: #dbeafe;
    color: #1e40af;
    text-transform: uppercase;
  }

  .todos-points {
    padding: 0.125rem 0.5rem;
    border-radius: 9999px;
    font-size: 0.75rem;
    font-weight: 600;
    background: #fef3c7;
    color: #92400e;
  }

  .stats-card {
    background: white;
    border-radius: 1rem;
    padding: 2rem;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  }

  .stats-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
    margin-bottom: 1.5rem;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  .stats-item {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    padding: 1rem;
    background: #f9fafb;
    border-radius: 8px;
  }

  .stats-item-label {
    font-size: 0.75rem;
    font-weight: 500;
    color: #6b7280;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .stats-item-value {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1d1d1f;
  }

  .stats-streak {
    margin-top: 1rem;
    padding: 1rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 8px;
    color: white;
  }

  .stats-streak-label {
    font-size: 0.75rem;
    opacity: 0.9;
    margin-bottom: 0.25rem;
  }

  .stats-streak-value {
    font-size: 2rem;
    font-weight: 700;
  }
  """

  def render_template(assigns, attrs, state) do
    tasks = Map.get(assigns, :tasks, [])
    new_task = Map.get(assigns, :new_task, "")
    stats = Map.get(assigns, :stats, %{points_earned: 0, tasks_completed: 0, current_streak: 0, longest_streak: 0})
    show_recurring_form = Map.get(assigns, :show_recurring_form, false)
    recurrence_pattern = Map.get(assigns, :recurrence_pattern, "daily")
    points = Map.get(assigns, :points, 1)
    scheduled_date = Map.get(assigns, :scheduled_date, nil)
    scheduled_time = Map.get(assigns, :scheduled_time, nil)

    final_attrs = Keyword.put(attrs, :class, "todos-container")

    div(state, final_attrs, fn state ->
      state
      |> div([class: "container"], fn state ->
        state
        |> div([class: "todos-grid"], fn state ->
          state
          |> div([class: "todos-card"], fn state ->
            state
            |> h2([class: "todos-card-title"], "Task List")
            |> render_task_form(new_task, show_recurring_form, recurrence_pattern, points, scheduled_date, scheduled_time)
            |> render_task_list(tasks)
          end)
          |> render_stats_card(stats)
        end)
      end)
    end)
  end

  defp render_task_form(state, new_task, show_recurring_form, recurrence_pattern, points, scheduled_date, scheduled_time) do
    form(state, [class: "todos-form", phx_submit: "add_task"], fn state ->
      state
      |> div([class: "todos-form-row"], fn state ->
        state
        |> input([
          type: "text",
          name: "task",
          value: new_task,
          phx_change: "update_new_task",
          class: "todos-input",
          placeholder: "Add a new task..."
        ])
        |> button([type: "submit", class: "todos-add-button"], "Add")
      end)
      |> div([class: "todos-form-row"], fn state ->
        state
        |> label([
          class: "todos-recurring-toggle",
          phx_click: "toggle_recurring_form",
          phx_target: "this"
        ], fn state ->
          state
          |> input([
            type: "checkbox",
            checked: show_recurring_form,
            class: "todos-checkbox"
          ])
          |> span([], "Recurring Task")
        end)
        |> div([class: "todos-option-group"], fn state ->
          state
          |> label([class: "todos-option-label"], "Points")
          |> input([
            type: "number",
            name: "points",
            value: points,
            phx_change: "update_points",
            class: "todos-option-input",
            min: "1",
            max: "100"
          ])
        end)
      end)
      |> if(show_recurring_form, fn state ->
        div(state, [class: "todos-options"], fn state ->
          state
          |> div([class: "todos-option-group"], fn state ->
            state
            |> label([class: "todos-option-label"], "Pattern")
            |> select([
              name: "pattern",
              phx_change: "update_recurrence_pattern",
              class: "todos-option-input"
            ], fn state ->
              daily_attrs = if recurrence_pattern == "daily", do: [value: "daily", selected: true], else: [value: "daily"]
              weekly_attrs = if recurrence_pattern == "weekly", do: [value: "weekly", selected: true], else: [value: "weekly"]
              monthly_attrs = if recurrence_pattern == "monthly", do: [value: "monthly", selected: true], else: [value: "monthly"]

              state
              |> option(daily_attrs, "Daily")
              |> option(weekly_attrs, "Weekly")
              |> option(monthly_attrs, "Monthly")
            end)
          end)
          |> div([class: "todos-option-group"], fn state ->
            state
            |> label([class: "todos-option-label"], "Schedule Date")
            |> input([
              type: "date",
              name: "scheduled_date",
              value: if(scheduled_date, do: Date.to_iso8601(scheduled_date), else: ""),
              phx_change: "update_scheduled_date",
              class: "todos-option-input"
            ])
          end)
          |> div([class: "todos-option-group"], fn state ->
            state
            |> label([class: "todos-option-label"], "Schedule Time")
            |> input([
              type: "time",
              name: "scheduled_time",
              value: if(scheduled_time, do: Time.to_string(scheduled_time), else: ""),
              phx_change: "update_scheduled_time",
              class: "todos-option-input"
            ])
          end)
        end)
      end)
    end)
  end

  defp render_task_list(state, tasks) do
    ul(state, [class: "todos-list"], fn state ->
      Enum.reduce(tasks, state, fn task, acc_state ->
        render_task_item(acc_state, task)
      end)
    end)
  end

  defp render_task_item(state, task) do
    label_class = if task.completed, do: "todos-label completed", else: "todos-label"
    priority_class = "todos-priority #{task.priority}"

    li(state, [class: "todos-item"], fn state ->
      state
      |> input([
        type: "checkbox",
        id: "task-#{task.id}",
        checked: task.completed,
        phx_click: "toggle",
        phx_value_id: task.id,
        class: "todos-checkbox"
      ])
      |> label([for: "task-#{task.id}", class: label_class], fn state ->
        state
        |> span([class: "todos-label-title"], task.title)
        |> span([class: "todos-label-meta"], fn state ->
          state
          |> if(task.is_recurring, fn state ->
            span(state, [class: "todos-recurring-badge"], String.capitalize(task.recurrence_pattern || "recurring"))
          end)
          |> span([class: "todos-points"], "+#{task.points || 1} pts")
          |> if(task.completion_count > 0, fn state ->
            span(state, [], "✓ #{task.completion_count}")
          end)
        end)
      end)
      |> span([class: priority_class], String.capitalize(task.priority))
    end)
  end

  defp render_stats_card(state, stats) do
    div(state, [class: "stats-card"], fn state ->
      state
      |> h2([class: "stats-title"], "Today's Stats")
      |> div([class: "stats-grid"], fn state ->
        state
        |> div([class: "stats-item"], fn state ->
          state
          |> div([class: "stats-item-label"], "Points")
          |> div([class: "stats-item-value"], "#{stats.points_earned}")
        end)
        |> div([class: "stats-item"], fn state ->
          state
          |> div([class: "stats-item-label"], "Completed")
          |> div([class: "stats-item-value"], "#{stats.tasks_completed}")
        end)
      end)
      |> div([class: "stats-streak"], fn state ->
        state
        |> div([class: "stats-streak-label"], "Current Streak")
        |> div([class: "stats-streak-value"], "#{stats.current_streak} days")
        |> div([class: "stats-streak-label", style: "margin-top: 0.5rem;"], "Longest Streak")
        |> div([class: "stats-streak-value", style: "font-size: 1.25rem;"], "#{stats.longest_streak} days")
      end)
    end)
  end

  # Helper to conditionally render
  defp if(state, condition, fun) when condition, do: fun.(state)
  defp if(state, _condition, _fun), do: state
end
