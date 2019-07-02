#!/usr/bin/env bash

echo "Using OR_PORT=${OR_PORT}, PT_PORT=${PT_PORT}, and EMAIL=${EMAIL}."

cat > /etc/tor/torrc << EOF
RunAsDaemon 0
# We don't need an open SOCKS port.
SocksPort 0
BridgeRelay 1
# A static nickname makes it easy to identify bridges that were set up in this
# Docker container.
Nickname DockerObfs4Bridge
Log notice file /var/log/tor/log
ServerTransportPlugin obfs4 exec /usr/bin/obfs4proxy
ExtORPort auto

# The variable "OR_PORT" is replaced with a randomly-generated OR port by the
# script deploy-container.sh.
ORPort ${OR_PORT}

# The variable "PT_PORT" is replaced with a randomly-generated port by the
# script deploy-container.sh.
ServerTransportListenAddr obfs4 0.0.0.0:${PT_PORT}

# The variable "EMAIL" is replaced with the operator's email address by the
# script deploy-container.sh.
ContactInfo ${EMAIL}
EOF

echo "Starting tor."
tor -f /etc/tor/torrc
