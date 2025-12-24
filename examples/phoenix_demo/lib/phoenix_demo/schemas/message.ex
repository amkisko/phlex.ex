defmodule PhoenixDemo.Schemas.Message do
  use Ecto.Schema

  schema "messages" do
    field :sender, :string
    field :text, :string
    field :type, :string, default: "sent"

    timestamps(type: :utc_datetime, inserted_at: :inserted_at, updated_at: false)
  end
end

