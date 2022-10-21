defmodule UrlShortenerWeb.ShortenedUrlController do
  use UrlShortenerWeb, :controller

  alias UrlShortener.{ShortenedUrl, ShortenedUrlRepo}

  action_fallback UrlShortenerWeb.FallbackController

  def new(conn, _params) do
    changeset = ShortenedUrl.changeset(%{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shortened_url" => shortened_url_params}) do
    case ShortenedUrlRepo.create_shortened_url(shortened_url_params) do
      {:ok, shortened_url} ->
        conn
        |> put_flash(:info, "Shortened url created successfully")
        |> redirect(to: Routes.shortened_url_path(conn, :show, shortened_url.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> render("new.html", changeset: changeset)

      error -> error
    end
  end

  def show(conn, %{"id" => slug}) do
    case ShortenedUrlRepo.get_shortened_url(slug) do
      {:ok, shortened_url} ->
        render(conn, "show.html", shortened_url: shortened_url)

      error -> error
    end
  end

  def redirection(conn, %{"slug" => slug}) do
    case ShortenedUrlRepo.get_shortened_url(slug) do
      {:ok, shortened_url} ->
        redirect(conn, external: shortened_url.original_url)

      error -> error
    end
  end
end
