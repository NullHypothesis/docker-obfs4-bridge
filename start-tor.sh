#!/usr/bin/env bash

echo "Using OR_PORT=${OR_PORT}, PT_PORT=${PT_PORT}, and EMAIL=${EMAIL}."

# Add configuration from docker-compose's environment
cat > /etc/tor/torrc.d/env << EOF
ORPort ${OR_PORT}
ServerTransportListenAddr obfs4 0.0.0.0:${PT_PORT}
ContactInfo ${EMAIL}
EOF

if which nyx >/dev/null 2>&1; then
    echo "Adding configuration for Nyx connection"
    cat > /etc/tor/torrc.d/nyx << EOF
# Enable local access for Nyx
ControlPort 9051
CookieAuthentication 1
EOF
fi

echo "Starting tor."
exec tor -f /etc/tor/torrc
