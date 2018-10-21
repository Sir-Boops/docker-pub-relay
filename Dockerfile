FROM ubuntu:18.04 as builder

# Build the pub-relay
ENV PUB_HASH="a7c154a5c32088a72917283e869e9bbfa0672501"
RUN apt update && \
    apt dist-upgrade && \
    apt autoremove && \
    apt install gnupg curl -y && \
    curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add - && \
    echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list && \
    apt update && \
    apt install crystal libgmp-dev zlib1g-dev libssl1.0-dev -y && \
    cd ~ && \
    git clone https://source.joinmastodon.org/mastodon/pub-relay.git && \
    cd pub-relay && \
    shards build --release

FROM ubuntu:18.04
COPY --from=builder /root/pub-relay /root/pub-relay
RUN apt update && \
    apt dist-upgrade && \
    apt auto-remove && \
    apt install libssl1.0 libevent-2.1-6 ca-certificates

# Add Extra ENVs
ENV RELAY_DEBUG="true"

# Start the relay
CMD /root/pub-relay/bin/pub-relay
