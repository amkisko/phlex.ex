defmodule PhoenixDemo.Schemas.Article do
  use Ecto.Schema

  schema "articles" do
    field :title, :string
    field :author, :string
    field :date, :date
    field :excerpt, :string
    field :content, :string
    field :category, :string

    timestamps(type: :utc_datetime)
  end
end

