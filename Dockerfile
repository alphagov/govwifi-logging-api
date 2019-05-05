FROM ruby:2.6.1-alpine
ARG BUNDLE_INSTALL_CMD

ENV S3_PUBLISHED_LOCATIONS_IPS_BUCKET 'stub-bucket'
ENV S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY 'stub-key'

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock .ruby-version ./
RUN apk --no-cache add build-base mysql-dev && \
  ${BUNDLE_INSTALL_CMD} && \
  apk del build-base

COPY . .

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8080"]
