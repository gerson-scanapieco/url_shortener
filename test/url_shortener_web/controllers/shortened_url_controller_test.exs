defmodule UrlShortenerWeb.ShortenedUrlControllerTest do
  use UrlShortenerWeb.ConnCase

  alias UrlShortener.ShortenedUrlRepo

  @create_attrs %{original_url: "http://dummy.com"}
  @invalid_attrs %{original_url: nil}

  describe "new/2" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.shortened_url_path(conn, :new))
      assert html_response(conn, 200) =~ "New Shortened url"
    end
  end

  describe "create/2" do
    test "creates the ShortenedURL and redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.shortened_url_path(conn, :create), shortened_url: @create_attrs)

      assert ShortenedUrlRepo.count_shortened_url() == 1

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.shortened_url_path(conn, :show, id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.shortened_url_path(conn, :create), shortened_url: @invalid_attrs)
      assert html_response(conn, 422) =~ "Oops, something went wrong!"
    end
  end

  describe "show/2" do
    test "renders the ShortenedUrl", %{conn: conn} do
      {:ok, shortened_url} =
        ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      conn = get(conn, Routes.shortened_url_path(conn, :show, shortened_url))
      assert html_response(conn, 200) =~ "http://dummy.com"
    end

    test "renders not found page when ShortenedUrl is not found", %{conn: conn} do
      conn = get(conn, Routes.shortened_url_path(conn, :show, "inexistent_id"))
      assert html_response(conn, 404) =~ "Not Found"
    end
  end

  describe "redirection/2" do
    test "finds the ShortenedUrl by its slug and redirects to the original_url", %{conn: conn} do
      {:ok, shortened_url} =
        ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      conn = get(conn, Routes.redirection_url_path(conn, :redirection, shortened_url))
      assert html_response(conn, 302)
    end

    test "renders not found page when the slug does not exists", %{conn: conn} do
      conn = get(conn, Routes.redirection_url_path(conn, :redirection, "inexistent_slug"))
      assert html_response(conn, 404) =~ "Not Found"
    end
  end
end
