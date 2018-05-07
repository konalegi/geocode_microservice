FROM ruby:2.4.1
MAINTAINER Danil Nurgaliev <jkonalegi@gmail.com>

ENV LANG C.UTF-8

RUN apt-get update -qq && \
    apt-get install -y build-essential --fix-missing --no-install-recommends \
    bc build-essential libpq-dev libgmp-dev

ENV RAILS_ROOT /var/www/app
RUN mkdir -p $RAILS_ROOT/tmp/pids

WORKDIR $RAILS_ROOT

RUN gem install bundler

ADD Gemfile* $RAILS_ROOT/
RUN bundle install --jobs 7 --retry 3

ADD . $RAILS_ROOT

HEALTHCHECK --interval=15s --timeout=3s \
  CMD curl -f http://localhost:3000/health_check?health_check_security_token="$HEALTH_CHECK_SECURITY_TOKEN" || exit 1

EXPOSE 3000

ENTRYPOINT ["/var/www/app/bin/prod-entrypoint.sh"]
