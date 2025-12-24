defmodule PhoenixDemo.Schemas.UserStat do
  use Ecto.Schema

  schema "user_stats" do
    field :date, :date
    field :points_earned, :integer, default: 0
    field :tasks_completed, :integer, default: 0
    field :current_streak, :integer, default: 0
    field :longest_streak, :integer, default: 0

    timestamps(type: :utc_datetime)
  end
end
