FROM crystallang/crystal:latest
RUN mkdir /opt/short
COPY . /opt/short/
WORKDIR /opt/short
RUN shards build
