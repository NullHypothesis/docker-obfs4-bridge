# Base docker image
FROM debian:jessie

LABEL maintainer="Philipp Winter <phw@torproject.org>"

# Install dependencies
RUN apt-get update && apt-get install -y \
    tor \
    obfs4proxy \
    --no-install-recommends

COPY torrc /etc/tor/torrc
COPY start-tor.sh /usr/local/bin

RUN chmod 0755 /usr/local/bin/start-tor.sh
RUN chmod 0644 /etc/tor/torrc

CMD [ "/usr/local/bin/start-tor.sh" ]
