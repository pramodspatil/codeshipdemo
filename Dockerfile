FROM ruby:2.2.1
MAINTAINER flo@codeship.com

RUN \
  apt-get update -y && \
  apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    apt-utils \
    vim git wget libfreetype6 libfontconfig bzip2
RUN mkdir -p /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
ADD vendor /app/vendor
RUN bundle install -j24

# Env
ENV PHANTOMJS_VERSION 1.9.7

# Commands

ADD . /app
