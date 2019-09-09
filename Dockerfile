# Base docker image
FROM debian:buster

LABEL maintainer="Philipp Winter <phw@torproject.org>"

# Install dependencies
RUN apt-get update && apt-get install -y \
    tor \
    tor-geoipdb \
    obfs4proxy \
    --no-install-recommends

# Our torrc is generated at run-time by the script start-tor.sh.
RUN rm /etc/tor/torrc
RUN chown debian-tor:debian-tor /etc/tor
RUN chown debian-tor:debian-tor /var/log/tor

COPY start-tor.sh /usr/local/bin
RUN chmod 0755 /usr/local/bin/start-tor.sh

USER debian-tor

CMD [ "/usr/local/bin/start-tor.sh" ]
