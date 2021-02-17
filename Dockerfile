FROM ruby:2.7-alpine

RUN apk update && apk add --no-cache curl
RUN gem install bundler

WORKDIR /app

COPY Gemfile* .

RUN bundle config set without "development test"
RUN bundle install

COPY bin/ /app/bin
COPY lib/ /app/lib

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

RUN chown 1000:1000 /app
USER 1000
