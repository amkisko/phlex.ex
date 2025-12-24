defmodule PhoenixDemo.Schemas.ArticleComment do
  use Ecto.Schema

  schema "article_comments" do
    field :article_id, :integer
    field :author, :string
    field :content, :string

    timestamps(type: :utc_datetime)
  end
end
