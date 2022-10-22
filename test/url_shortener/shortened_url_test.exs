defmodule UrlShortener.ShortenedUrlTest do
  use UrlShortener.DataCase

  alias UrlShortener.{Repo, ShortenedUrl}

  describe "validations" do
    test "is valid with scheme http" do
      changeset = ShortenedUrl.changeset(%{original_url: "http://google.com"})
      assert changeset.valid?
    end

    test "is valid with scheme https" do
      changeset = ShortenedUrl.changeset(%{original_url: "https://google.com"})
      assert changeset.valid?
    end

    test "is invalid when the original_url is not a valid URL" do
      changeset = ShortenedUrl.changeset(%{original_url: "<.>"})
      refute changeset.valid?

      assert errors_on(changeset) == %{original_url: ["is not a valid URL"]}
    end

    test "is invalid with schemes other than http or https" do
      changeset = ShortenedUrl.changeset(%{original_url: "amqp://google.com"})
      refute changeset.valid?

      assert errors_on(changeset) == %{original_url: ["must be HTTP or HTTPS"]}
    end

    test "is invalid with forbidden hosts" do
      for invalid_host <- ["localhost", "url-shortener"] do
        changeset = ShortenedUrl.changeset(%{original_url: "http://#{invalid_host}.com"})
        refute changeset.valid?

        assert errors_on(changeset) == %{original_url: ["is not a valid URL"]}
      end
    end

    test "is invalid when original_url is blank" do
      for absent_url <- [""] do
        changeset = ShortenedUrl.changeset(%{original_url: absent_url})
        refute changeset.valid?

        assert errors_on(changeset) == %{original_url: ["can't be blank"]}
      end
    end

    test "is invalid when original_url is longer than 2048 chars" do
      original_url = "http://google.com/" <> String.duplicate("a", 2048)
      changeset = ShortenedUrl.changeset(%{original_url: original_url})
      refute changeset.valid?

      assert errors_on(changeset) == %{original_url: ["should be at most 2048 character(s)"]}
    end
  end

  describe "changeset/1" do
    test "generates a unique slug for the original_url during persistence" do
      {:ok, shortened_url} =
        ShortenedUrl.changeset(%{original_url: "http://google.com"})
        |> Repo.insert()

      assert shortened_url.slug == ShortenedUrl.generate_slug("http://google.com")
    end
  end

  describe "generate_slug/1" do
    # Although MD5 always generates a 16 bytes digest, encoding it to
    # Base64 increases its size.
    test "generates a unique 22 bytes slug for the given string" do
      assert byte_size(ShortenedUrl.generate_slug("http://very-long-domain-name.com")) == 22
      assert byte_size(ShortenedUrl.generate_slug("http://a.com")) == 22

      assert byte_size(
               ShortenedUrl.generate_slug("http://google.com?query=1&query=2&query=3&query=4")
             ) ==
               22
    end

    test "the same input URL generates the same slug" do
      assert ShortenedUrl.generate_slug("http://google.com") ==
               ShortenedUrl.generate_slug("http://google.com")
    end
  end
end
