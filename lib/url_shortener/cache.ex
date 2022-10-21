defmodule UrlShortener.Cache do
  use Nebulex.Cache,
    otp_app: :url_shortener,
    adapter: Nebulex.Adapters.Local
end
