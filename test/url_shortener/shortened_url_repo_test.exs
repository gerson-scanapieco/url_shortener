defmodule UrlShortener.ShortenedUrlRepoTest do
  use UrlShortener.DataCase

  alias UrlShortener.{ShortenedUrl, ShortenedUrlRepo}

  describe "get_shortened_url/1" do
    test "returns the ShortenedUrl by the given slug" do
      {:ok, shortened_url} =
        ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      {:ok, _} = ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy2.com"})

      {:ok, db_shortened_url} = ShortenedUrlRepo.get_shortened_url(shortened_url.slug)

      assert db_shortened_url == shortened_url
    end

    test "returns :not_found error when the ShortenedUrl is not found" do
      assert ShortenedUrlRepo.get_shortened_url("inexistent_slug") == {:error, :not_found}
    end
  end

  describe "create_shortened_url/1" do
    test "persists the ShortenedUrl in the database with slug" do
      {:ok, shortened_url} =
        ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      assert shortened_url.original_url == "http://dummy.com"
      assert shortened_url.slug == ShortenedUrl.generate_slug("http://dummy.com")
    end

    test "returns the already persisted ShortenedUrl if original_url is already persisted" do
      {:ok, _} = ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      {:ok, shortened_url} =
        ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})

      assert ShortenedUrlRepo.count_shortened_url() == 1

      assert shortened_url.original_url == "http://dummy.com"
      assert shortened_url.slug == ShortenedUrl.generate_slug("http://dummy.com")
    end
  end

  describe "count_shortened_url" do
    test "returns the total ShortenedUrlRepo present in db" do
      {:ok, _} = ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy.com"})
      {:ok, _} = ShortenedUrlRepo.create_shortened_url(%{"original_url" => "http://dummy2.com"})

      assert ShortenedUrlRepo.count_shortened_url() == 2
    end
  end
end
