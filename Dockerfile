FROM crystallang/crystal:latest
RUN mkdir /opt/hurl
COPY . /opt/hurl/
WORKDIR /opt/hurl
RUN shards build
