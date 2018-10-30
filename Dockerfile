FROM ubuntu:18.04 as builder

# Build the pub-relay
ENV PUB_HASH="7cd94fd784687adf92e9cbd0e9c69c6aba6a3e11"
RUN apt update && \
    apt dist-upgrade -y && \
    apt autoremove -y && \
    apt install gnupg curl -y && \
    curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add - && \
    echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list && \
    apt update && \
    apt install crystal libgmp-dev zlib1g-dev libssl1.0-dev -y && \
    cd ~ && \
    git clone https://source.joinmastodon.org/mastodon/pub-relay.git && \
    cd pub-relay && \
	git checkout $PUB_HASH && \
    shards build --release

FROM ubuntu:18.04
COPY --from=builder /root/pub-relay/bin/pub-relay /root
RUN apt update && \
    apt dist-upgrade -y && \
    apt auto-remove -y && \
    apt -y install libssl1.0 libevent-2.1-6 ca-certificates

# Add Extra ENVs
ENV RELAY_DEBUG="true"

# Start the relay
CMD /root/pub-relay
