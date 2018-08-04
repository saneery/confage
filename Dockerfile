FROM elixir:1.6
RUN apt-get update
COPY . /app
WORKDIR /app
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y -q nodejs
RUN mix deps.get --only prod
ENV MIX_ENV prod
ENV PORT 4000
RUN mix compile
RUN cd ./assets && npm install -g brunch && npm install && brunch build -p
RUN mix phx.digest
CMD ["mix", "phx.server"]