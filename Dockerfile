# Base docker image
FROM debian:stable-slim

ARG with_nyx

LABEL maintainer="Philipp Winter <phw@torproject.org>"

# Install dependencies to add Tor's repository.
RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    gpg-agent \
    ca-certificates \
    libcap2-bin \
    --no-install-recommends

# See: <https://2019.www.torproject.org/docs/debian.html.en>
RUN curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
RUN gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

RUN printf "deb https://deb.torproject.org/torproject.org stable main\n" >> /etc/apt/sources.list.d/tor.list

# Install remaining dependencies.
RUN apt-get update && apt-get install -y --no-install-recommends \
    tor \
    tor-geoipdb \
    obfs4proxy

# Install nyx if requested
RUN if [ -n "$with_nyx" ]; then \
        apt-get install -y --no-install-recommends nyx; \
    fi

# Allow obfs4proxy to bind to ports < 1024.
RUN setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy

RUN chown debian-tor:debian-tor /etc/tor
RUN chown debian-tor:debian-tor /var/log/tor

RUN mkdir /etc/tor/torrc.d
RUN chown debian-tor:debian-tor /etc/tor/torrc.d

COPY torrc /etc/tor
RUN chown debian-tor:debian-tor /etc/tor/torrc

COPY start-tor.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/start-tor.sh

COPY get-bridge-line /usr/local/bin
RUN chmod 0755 /usr/local/bin/get-bridge-line

USER debian-tor

CMD [ "/usr/local/bin/start-tor.sh" ]
