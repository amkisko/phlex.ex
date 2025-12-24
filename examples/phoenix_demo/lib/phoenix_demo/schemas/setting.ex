defmodule PhoenixDemo.Schemas.Setting do
  use Ecto.Schema

  @primary_key {:id, :string, autogenerate: false}
  schema "settings" do
    field :site_name, :string, default: "DemoApp"
    field :maintenance_mode, :boolean, default: false
    field :max_reservations, :integer, default: 100

    timestamps(type: :utc_datetime)
  end
end
