defmodule PhoenixDemo.Schemas.ArticleLike do
  use Ecto.Schema

  schema "article_likes" do
    field :article_id, :integer
    field :user_ip, :string

    timestamps(type: :utc_datetime)
  end
end
