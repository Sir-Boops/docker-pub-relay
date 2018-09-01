FROM alpine:3.8

# Build the pub-relay
ENV PUB_HASH="a8891a43d7ca95fb7bdcae348b39e20c6acce74b"
RUN	apk -U upgrade && \
	apk add --virtual deps crystal \
		shards libressl-dev musl-dev zlib-dev && \
	cd ~ && \
	git clone https://source.joinmastodon.org/mastodon/pub-relay && \
	cd pub-relay && \
	git checkout $PUB_HASH && \
	shards build && \
	mkdir -p /opt/pub-relay && \
	mv bin /opt/pub-relay/ && \
	apk add gmp pcre gc libevent libgcc ca-certificates && \
	apk del --purge deps && \
	rm -rf ~/* && \
	cp /opt/pub-relay/bin/worker /

ENV PATH="${PATH}:/opt/pub-relay/bin"

# Add Extra ENVs
ENV RELAY_HOST="0.0.0.0"
ENV REDIS_URL="redis://redis:6379"
