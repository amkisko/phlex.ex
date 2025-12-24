defmodule PhoenixDemoWeb.TodosLive do
  use PhoenixDemoWeb, :live_view

  import Ecto.Query
  import Ecto.Changeset

  alias PhoenixDemo.Repo
  alias PhoenixDemo.Schemas.{Task, UserStat}

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()

    # Get all tasks, including recurring ones that are due today
    tasks = load_tasks(today)

    # Get today's stats
    stats = get_or_create_today_stats(today)

    {:ok,
     socket
     |> assign(:new_task, "")
     |> assign(:tasks, tasks)
     |> assign(:stats, stats)
     |> assign(:today, today)
     |> assign(:show_recurring_form, false)
     |> assign(:recurrence_pattern, "daily")
     |> assign(:points, 1)
     |> assign(:scheduled_date, nil)
     |> assign(:scheduled_time, nil)}
  end

  @impl true
  def handle_event("add_task", %{"task" => task}, socket) when task != "" do
    # Get next ID
    max_id = Repo.aggregate(Task, :max, :id) || 0
    next_id = max_id + 1

    new_task =
      %Task{
        id: next_id,
        title: task,
        completed: false,
        priority: "medium",
        points: socket.assigns.points,
        is_recurring: socket.assigns.show_recurring_form,
        recurrence_pattern: if(socket.assigns.show_recurring_form, do: socket.assigns.recurrence_pattern, else: nil),
        scheduled_date: socket.assigns.scheduled_date,
        scheduled_time: socket.assigns.scheduled_time,
        next_due_date: calculate_next_due_date(socket.assigns.recurrence_pattern, socket.assigns.today)
      }
      |> Repo.insert!()

    task_data = format_task(new_task)
    updated_tasks = socket.assigns.tasks ++ [task_data]

    {:noreply,
     socket
     |> assign(:tasks, updated_tasks)
     |> assign(:new_task, "")
     |> assign(:show_recurring_form, false)
     |> assign(:points, 1)
     |> assign(:scheduled_date, nil)
     |> assign(:scheduled_time, nil)}
  end

  def handle_event("add_task", _params, socket), do: {:noreply, socket}

  def handle_event("toggle", %{"id" => id}, socket) do
    task_id = String.to_integer(id)
    task = Repo.get!(Task, task_id)
    today = socket.assigns.today

    if task.completed do
      # Uncompleting - just mark as incomplete
      updated_task = Repo.update!(change(task, completed: false, completion_date: nil))
      updated_tasks = update_task_in_list(socket.assigns.tasks, updated_task)
      {:noreply, assign(socket, :tasks, updated_tasks)}
    else
      # Completing - award points, update stats, handle recurrence
      completion_date = DateTime.utc_now()

      changes = %{
        completed: true,
        completion_date: completion_date,
        last_completed_date: completion_date,
        completion_count: (task.completion_count || 0) + 1
      }

      # If recurring, reset for next occurrence
      changes = if task.is_recurring do
        Map.put(changes, :completed, false)
        |> Map.put(:next_due_date, calculate_next_due_date(task.recurrence_pattern, today))
      else
        changes
      end

      _updated_task = Repo.update!(change(task, changes))

      # Update stats
      update_today_stats(socket.assigns.today, task.points || 1)

      # Reload tasks to get updated recurring tasks
      updated_tasks = load_tasks(today)
      updated_stats = get_or_create_today_stats(today)

      {:noreply,
       socket
       |> assign(:tasks, updated_tasks)
       |> assign(:stats, updated_stats)}
    end
  end

  def handle_event("update_new_task", %{"task" => task}, socket) do
    {:noreply, assign(socket, :new_task, task)}
  end

  def handle_event("toggle_recurring_form", _params, socket) do
    {:noreply, assign(socket, :show_recurring_form, !socket.assigns.show_recurring_form)}
  end

  def handle_event("update_recurrence_pattern", %{"pattern" => pattern}, socket) do
    {:noreply, assign(socket, :recurrence_pattern, pattern)}
  end

  def handle_event("update_points", %{"points" => points}, socket) do
    points_int = case Integer.parse(points) do
      {p, _} -> p
      :error -> 1
    end
    {:noreply, assign(socket, :points, max(1, min(100, points_int)))}
  end

  def handle_event("update_scheduled_date", %{"date" => date}, socket) do
    scheduled_date = case Date.from_iso8601(date) do
      {:ok, d} -> d
      _ -> nil
    end
    {:noreply, assign(socket, :scheduled_date, scheduled_date)}
  end

  def handle_event("update_scheduled_time", %{"time" => time}, socket) do
    scheduled_time = case Time.from_iso8601(time <> ":00") do
      {:ok, t} -> t
      _ -> nil
    end
    {:noreply, assign(socket, :scheduled_time, scheduled_time)}
  end

  @impl true
  def render(assigns) do
    component_assigns = %{
      tasks: assigns.tasks,
      new_task: assigns.new_task,
      stats: assigns.stats,
      show_recurring_form: assigns.show_recurring_form,
      recurrence_pattern: assigns.recurrence_pattern,
      points: assigns.points,
      scheduled_date: assigns.scheduled_date,
      scheduled_time: assigns.scheduled_time
    }

    PhoenixDemoWeb.Components.PhlexRenderer.to_rendered(
      PhoenixDemoWeb.Components.Todos.render(component_assigns)
    )
  end

  # Helper functions

  defp load_tasks(_today) do
    # Get all non-recurring tasks
    non_recurring = Repo.all(
      from t in Task,
        where: t.is_recurring == false,
        order_by: [desc: t.inserted_at],
        select: %{
          id: t.id,
          title: t.title,
          completed: t.completed,
          priority: t.priority,
          points: t.points,
          is_recurring: false,
          scheduled_date: t.scheduled_date,
          scheduled_time: t.scheduled_time,
          completion_count: t.completion_count
        }
    )

    # Get recurring tasks that are due today or overdue
    recurring_due = Repo.all(
      from t in Task,
        where: t.is_recurring == true,
        where: is_nil(t.next_due_date) or t.next_due_date <= ^DateTime.utc_now(),
        order_by: [asc: t.next_due_date],
        select: %{
          id: t.id,
          title: t.title,
          completed: t.completed,
          priority: t.priority,
          points: t.points,
          is_recurring: true,
          recurrence_pattern: t.recurrence_pattern,
          next_due_date: t.next_due_date,
          scheduled_date: t.scheduled_date,
          scheduled_time: t.scheduled_time,
          completion_count: t.completion_count
        }
    )

    (non_recurring ++ recurring_due)
    |> Enum.map(&format_task/1)
  end

  defp format_task(%Task{} = task) do
    %{
      id: task.id,
      title: task.title,
      completed: task.completed,
      priority: task.priority || "medium",
      points: task.points || 1,
      is_recurring: task.is_recurring || false,
      recurrence_pattern: task.recurrence_pattern,
      scheduled_date: task.scheduled_date,
      scheduled_time: task.scheduled_time,
      completion_count: task.completion_count || 0
    }
  end

  defp format_task(map) when is_map(map), do: map

  defp update_task_in_list(tasks, updated_task) do
    Enum.map(tasks, fn t ->
      if t.id == updated_task.id do
        format_task(updated_task)
      else
        t
      end
    end)
  end

  defp calculate_next_due_date("daily", today) do
    today
    |> Date.add(1)
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp calculate_next_due_date("weekly", today) do
    today
    |> Date.add(7)
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp calculate_next_due_date("monthly", today) do
    today
    |> Date.add(30)
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp calculate_next_due_date(_, today) do
    today
    |> Date.add(1)
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end

  defp get_or_create_today_stats(today) do
    case Repo.get_by(UserStat, date: today) do
      nil ->
        # Calculate streak from previous days
        streak = calculate_current_streak(today)
        longest_streak = get_longest_streak()

        %UserStat{
          date: today,
          points_earned: 0,
          tasks_completed: 0,
          current_streak: streak,
          longest_streak: longest_streak
        }
        |> Repo.insert!()
        |> format_stats()

      stat ->
        format_stats(stat)
    end
  end

  defp format_stats(%UserStat{} = stat) do
    %{
      points_earned: stat.points_earned || 0,
      tasks_completed: stat.tasks_completed || 0,
      current_streak: stat.current_streak || 0,
      longest_streak: stat.longest_streak || 0
    }
  end

  defp format_stats(map) when is_map(map), do: map

  defp update_today_stats(today, points) do
    stat = Repo.get_by!(UserStat, date: today)

    changes = %{
      points_earned: (stat.points_earned || 0) + points,
      tasks_completed: (stat.tasks_completed || 0) + 1
    }

    # Update streak if this is the first task completed today
    changes = if stat.tasks_completed == 0 do
      new_streak = (stat.current_streak || 0) + 1
      longest_streak = max(stat.longest_streak || 0, new_streak)

      Map.merge(changes, %{
        current_streak: new_streak,
        longest_streak: longest_streak
      })
    else
      changes
    end

    Repo.update!(change(stat, changes))

    # Update streak for previous days if broken
    update_streak_if_broken(today)
  end

  defp calculate_current_streak(today) do
    yesterday = Date.add(today, -1)

    case Repo.get_by(UserStat, date: yesterday) do
      nil -> 0
      stat -> stat.current_streak || 0
    end
  end

  defp get_longest_streak do
    case Repo.one(
      from s in UserStat,
        select: max(s.longest_streak)
    ) do
      nil -> 0
      max_streak -> max_streak
    end
  end

  defp update_streak_if_broken(today) do
    # Check if yesterday had tasks completed
    yesterday = Date.add(today, -1)

    case Repo.get_by(UserStat, date: yesterday) do
      nil ->
        # Yesterday had no stats, so streak is broken
        # Reset streak for today if it was > 0
        stat = Repo.get_by!(UserStat, date: today)
        if stat.current_streak > 0 do
          Repo.update!(change(stat, current_streak: 1))
        end

      _ ->
        # Yesterday had stats, streak continues
        :ok
    end
  end
end
