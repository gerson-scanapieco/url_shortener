defmodule UrlShortener.Repo.Migrations.AddShortenedUrlsTable do
  use Ecto.Migration

  def change do
    create table(:shortened_urls, primary_key: false) do
      add :original_url, :text, null: false
      add :slug, :text, null: false, primary_key: true

      timestamps()
    end

    create index("shortened_urls", [:slug], unique: true)
  end
end
