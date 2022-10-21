# UrlShortener

URL shortener application, in the same vein as [bitly](https://bitly.com) and [tinyurl](https://tinyurl.com/app).

Please refer to `notes.txt` for more detailed information about the app's design.

## Setup

### Prerequisites

#### Installing Elixir

We recommend using [asdf](https://asdf-vm.com/guide/getting-started.html) to manage the Erlang/Elixir versions installed in
your system. Please follow [these instructions](https://www.pluralsight.com/guides/installing-elixir-erlang-with-asdf) to install
the necessary plugins before installing Elixir.

#### Docker

This project uses Docker to manage the app's dependencies. Please follow [these instructions](https://docs.docker.com/engine/install/) to
install the Docker runtime in your machine.

### Initial setup

You can choose to run the app via Docker compose or in your host machine. If you want to run it via Compose, run `make docker-run`
and the container shall be started.

But if you prefer to run the app in your host machine, run `make server` instead. This will require that you run `make setup` first,
so the project is correctly configured in your machine.

**Note**: Remember to check your `.env` file so the environment variables are correctly configured for either docker or the local server.
Some variables may need adjustment, like the `DATABASE_URL` one.

Now you can visit [`localhost:8080`](http://localhost:8080) from your browser.

### Configuration

The app uses environment variables for runtime configuration. They can be configured locally by edditing the `.env` file created once
you run `make setup`.
