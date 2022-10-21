.PHONY: $(MAKECMDGOALS)

LOCAL_ENV := $(shell cat .env 2> /dev/null | sed "s/\#.*$$//")

elixir-install:
	asdf install

mix-install:
	mix deps.get

env:
	cp .env.example .env

dependencies-up:
	docker compose up -d db

dependencies-down:
	docker compose down

db-setup: env dependencies-up
	export $(LOCAL_ENV) && \
	mix ecto.setup

docker-build:
	docker build --tag url_shortener:release .

docker-run: dependencies-up
	docker compose up -d url_shortener

# `make setup` will be used after cloning or downloading to fulfill
# dependencies, and setup the the project in an initial state.
# This is where you might download rubygems, node_modules, packages,
# compile code, build container images, initialize a database,
# anything else that needs to happen before your server is started
# for the first time
setup: elixir-install env mix-install db-setup

# `make server` will be used after `make setup` in order to start
# an http server process that listens on any unreserved port
#	of your choice (e.g. 8080).
server:
	export $(LOCAL_ENV) && \
	mix phx.server

# `make test` will be used after `make setup` in order to run
# your test suite.
test: dependencies-up
	mix test