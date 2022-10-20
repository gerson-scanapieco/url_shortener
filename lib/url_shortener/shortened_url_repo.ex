defmodule UrlShortener.ShortenedUrlRepo do
  @moduledoc """
  The ShortenedUrls repository module, responsible for
  acessing ShortenedUrls in the database.
  """

  alias UrlShortener.{Repo, ShortenedUrl}

  def get_shortened_url(slug) do
    case Repo.get(ShortenedUrl, slug) do
      nil -> {:error, :not_found}
      shortened_url -> {:ok, shortened_url}
    end
  end

  def create_shortened_url(attrs \\ %{}) do
    try do
      ShortenedUrl.changeset(attrs)
      |> Repo.insert()
    rescue
      Ecto.ConstraintError ->
        slug = ShortenedUrl.generate_slug(attrs["original_url"])
        get_shortened_url(slug)
    end
  end

  def count_shortened_url() do
    Repo.aggregate(ShortenedUrl, :count)
  end
end
