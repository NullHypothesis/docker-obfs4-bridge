#!/usr/bin/env bash

echo "Using OR_PORT=${OR_PORT}, PT_PORT=${PT_PORT}, and EMAIL=${EMAIL}."

# Add configuration from docker-compose's environment
cat > /etc/tor/torrc.d/env << EOF
ORPort ${OR_PORT}
ServerTransportListenAddr obfs4 0.0.0.0:${PT_PORT}
ContactInfo ${EMAIL}
EOF

echo "Starting tor."
tor -f /etc/tor/torrc
