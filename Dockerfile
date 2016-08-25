FROM ruby:2.3.1-slim
MAINTAINER maintainers@codeship.com

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PHANTOMJS_VERSION=1.9.7

RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    bzip2 \
    git \
    libfontconfig \
    libfreetype6 \
    libpq-dev \
    nodejs \
    python-pip \
    time \
    vim \
    wget \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && pip install awscli

RUN \
  wget --output-document /tmp/phantomjs-linux-x86_64.tar.bz2 "https://s3.amazonaws.com/codeship-packages/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64.tar.bz2" \
  && tar -xaf /tmp/phantomjs-linux-x86_64.tar.bz2 --directory /tmp/ \
  && mv "/tmp/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64/bin/phantomjs" /usr/bin/phantomjs \
  && rm -rf /tmp/phantomjs-linux-x86_64.tar.bz2 "/tmp/phantomjs-${PHANTOMJS_VERSION}-linux-x86_64"

COPY Gemfile Gemfile.lock vendor /app/
RUN \
  cd /app/ \
  && bundle install --jobs 20 --retry 5 \
  && gem install parallel_tests

WORKDIR /code
