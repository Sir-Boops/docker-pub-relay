FROM ubuntu:18.04 as build-deps

# Install Crystal
ENV CRYSTAL_VER="0.26.0"
RUN apt update && \
	echo "Etc/UTC" > /etc/localtime && \
	apt -y install wget tzdata && \
	dpkg-reconfigure --frontend noninteractive tzdata && \
	apt dist-upgrade -y && \
	cd ~ && \
	wget https://github.com/crystal-lang/crystal/releases/download/$CRYSTAL_VER/crystal-$CRYSTAL_VER-1-linux-x86_64.tar.gz && \
	tar xf crystal-$CRYSTAL_VER-1-linux-x86_64.tar.gz && \
	mkdir -p /opt/ && \
	mv crystal-$CRYSTAL_VER-1/ /opt/crystal && \
	rm -rf ~/*

# Add Crystal to the path
ENV PATH="${PATH}:/opt/crystal/bin"

# Install the pub-relay
ENV RELAY_HASH="2894b8fb7088e22e28ad539ee0bfd15f6418098f"
RUN apt -y install git gcc libpcre3-dev libevent-dev \
		libgmp-dev zlib1g-dev libssl1.0-dev && \
	cd ~ && \
	git clone https://source.joinmastodon.org/mastodon/pub-relay && \
	cd pub-relay && \
	git checkout $RELAY_HASH && \
	shards build --production

# Add relay to path
ENV PATH="${PATH}:/opt/pub-relay/bin"

FROM ubuntu:18.04

RUN apt update && \
	echo "Etc/UTC" > /etc/localtime && \
	apt install tzdata && \
	dpkg-reconfigure --frontend noninteractive tzdata && \
	apt dist-upgrade -y && \
	apt install libssl1.0 libevent-2.1

# Copy over the relay software
COPY --from=build-deps /root/pub-relay /opt/pub-relay

# Add relay to path
ENV PATH="${PATH}:/opt/pub-relay/bin"

# Add Extra ENVs
ENV RELAY_HOST="0.0.0.0"
ENV REDIS_URL="redis://redis:6379"
