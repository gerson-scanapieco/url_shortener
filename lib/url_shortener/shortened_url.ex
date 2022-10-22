defmodule UrlShortener.ShortenedUrl do
  use Ecto.Schema
  import Ecto.Changeset

  alias UrlShortener.ShortenedUrl

  @primary_key {:slug, :string, []}

  @derive {Phoenix.Param, key: :slug}

  @allowed_schemes ["http", "https"]

  # Arbitrary length for a maximum URL. Although URLs can technically be huge,
  # we set this limit so we are less vulnerable to attacks spamming long URLs
  # and keep things manageable.
  @max_original_url_length 2048

  # List of fobidden hosts:
  #
  # localhost -> it does not make sense to shorten a local-only URL
  # url-shortener -> placeholder for the public domain of the url-shortener project.
  #                  The idea is to avoid shortening already shortened URLs so we
  #                  don't fall into redirect loops.
  @forbidden_hosts ~r/(localhost|url-shortener)/

  schema "shortened_urls" do
    field :original_url, :string

    timestamps()
  end

  def changeset(params) do
    %ShortenedUrl{}
    |> cast(params, [:original_url])
    |> validate_required([:original_url])
    |> validate_length(:original_url, max: @max_original_url_length)
    |> validate_original_url_format()
    |> prepare_changes(fn changeset ->
      insert_slug(changeset)
    end)
  end

  # Generates a slug for the given URL using the MD5 hashing algorithm.
  # In my analisys, the generated 128 bits digest offers a good trade-off
  # between digest size and collision probability. Although MD5 is not
  # recommended anymore for criptographic workloads, it works well for
  # our scenario where we just want a determinist digest for a given URL.
  def generate_slug(original_url) do
    original_url
    |> then(&:crypto.hash(:md5, &1))
    |> Base.url_encode64(padding: false)
  end

  defp validate_original_url_format(changeset) do
    validate_change(changeset, :original_url, fn :original_url, original_url ->
      case URI.new(original_url) do
        {:ok, url} ->
          cond do
            url.scheme not in @allowed_schemes -> [original_url: "must be HTTP or HTTPS"]
            String.match?(url.host, @forbidden_hosts) -> [original_url: "is not a valid URL"]
            true -> []
          end

        _ ->
          [original_url: "is not a valid URL"]
      end
    end)
  end

  defp insert_slug(changeset) do
    digest =
      changeset
      |> get_change(:original_url)
      |> generate_slug()

    put_change(changeset, :slug, digest)
  end
end
