FROM ruby:alpine
WORKDIR /app
COPY . /app
RUN apk add --no-cache build-base
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community can-utils
RUN ["bundle", "install"]
CMD ["/app/rvc2mqtt.rb"]
