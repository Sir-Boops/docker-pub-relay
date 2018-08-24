FROM alpine:3.8

# Build the pub-relay
ENV PUB_HASH="2894b8fb7088e22e28ad539ee0bfd15f6418098f"
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
	apk add gmp pcre gc libevent libgcc && \
	apk del --purge deps && \
	rm -rf ~/*

ENV PATH="${PATH}:/opt/pub-relay/bin"

# Add Extra ENVs
ENV RELAY_HOST="0.0.0.0"
ENV REDIS_URL="redis://redis:6379"
