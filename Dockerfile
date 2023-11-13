FROM ruby:3.2.2-alpine

ENV S3_PUBLISHED_LOCATIONS_IPS_BUCKET 'stub-bucket'
ENV S3_PUBLISHED_LOCATIONS_IPS_OBJECT_KEY 'stub-key'

WORKDIR /usr/src/app


COPY Gemfile Gemfile.lock .ruby-version ./

ARG BUNDLE_INSTALL_CMD 
RUN apk --no-cache add --virtual .build-deps build-base && \
  apk --no-cache add mysql-dev && \
  apk --no-cache add git && \
  ${BUNDLE_INSTALL_CMD} && \
  apk del .build-deps

COPY . .


COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-p", "8080", "--quiet", "--threads", "8:32"]
