defmodule PhoenixDemo.Schemas.Reservation do
  use Ecto.Schema

  schema "reservations" do
    field :customer_name, :string
    field :customer_email, :string
    field :customer_phone, :string
    field :check_in, :date
    field :check_out, :date
    field :guests, :integer, default: 1
    field :room_type, :string
    field :special_requests, :string
    field :status, :string, default: "pending"

    belongs_to :customer, PhoenixDemo.Schemas.Customer

    timestamps(type: :utc_datetime)
  end
end

