defmodule PhoenixDemo.Schemas.Task do
  use Ecto.Schema

  schema "tasks" do
    field :title, :string
    field :completed, :boolean, default: false
    field :priority, :string, default: "medium"

    # Recurring task fields
    field :is_recurring, :boolean, default: false
    field :recurrence_pattern, :string  # "daily", "weekly", "monthly", "custom"
    field :recurrence_days, :string  # JSON array of days for weekly/monthly
    field :next_due_date, :utc_datetime

    # Schedule fields
    field :scheduled_date, :date
    field :scheduled_time, :time

    # Points and completion tracking
    field :points, :integer, default: 1
    field :completion_date, :utc_datetime
    field :last_completed_date, :utc_datetime

    # Progress tracking
    field :completion_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end
end
