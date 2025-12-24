defmodule PhoenixDemo.Schemas.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :phone, :string
    field :name, :string
    field :role, :string, default: "user"
    field :password_hash, :string
    field :webauthn_credential_id, :string
    field :webauthn_public_key, :string
    field :status, :string, default: "active"

    timestamps(type: :utc_datetime)
  end
end

