defmodule UrlShortenerWeb.ShortenedUrlView do
  use UrlShortenerWeb, :view

  def shortened_link(shortened_url) do
    UrlShortenerWeb.Endpoint.url() <> "/#{shortened_url.slug}"
  end
end
