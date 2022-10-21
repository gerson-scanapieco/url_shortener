defmodule UrlShortener.ShortenedUrlRepo do
  use Nebulex.Caching

  @moduledoc """
  The ShortenedUrls repository module, responsible for
  acessing ShortenedUrls in the database.
  """

  alias UrlShortener.{Cache, Repo, ShortenedUrl}

  @cache_ttl :timer.minutes(1)

  @decorate cacheable(cache: Cache, key: {ShortenedUrl, slug}, opts: [ttl: @cache_ttl])
  def get_shortened_url(slug) do
    case Repo.get(ShortenedUrl, slug) do
      nil -> {:error, :not_found}
      shortened_url -> {:ok, shortened_url}
    end
  end

  def create_shortened_url(attrs \\ %{}) do
    ShortenedUrl.changeset(attrs)
    |> Repo.insert()

  rescue
    Ecto.ConstraintError ->
      slug = ShortenedUrl.generate_slug(attrs["original_url"])
      get_shortened_url(slug)
  end

  def count_shortened_url do
    Repo.aggregate(ShortenedUrl, :count)
  end
end
