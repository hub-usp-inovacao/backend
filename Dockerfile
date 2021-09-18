##########
## Development Image
##########

FROM ruby:2.7.1-alpine as development

ENV PORT=3000 \
    APP_PATH=/usr/src/app \
    HOST=0.0.0.0 \
    RAILS_ENV=development

WORKDIR ${APP_PATH}

RUN apk add --update \
    build-base git bash && \
    gem install rails

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

COPY entrypoint.sh /usr/bin/

RUN chmod 755 /usr/bin/entrypoint.sh

ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]

EXPOSE ${PORT}

CMD rails server -b ${HOST}





##########
## Production Image
##########

FROM development as production

ENV RAILS_ENV=production

RUN rm -rf spec
