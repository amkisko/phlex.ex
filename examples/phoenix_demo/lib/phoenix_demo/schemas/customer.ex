defmodule PhoenixDemo.Schemas.Customer do
  use Ecto.Schema

  schema "customers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :status, :string, default: "active"
    field :total_reservations, :integer, default: 0
    field :total_spent, :integer, default: 0

    has_many :reservations, PhoenixDemo.Schemas.Reservation

    timestamps(type: :utc_datetime)
  end
end

