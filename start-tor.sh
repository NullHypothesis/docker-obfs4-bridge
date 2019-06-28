#!/usr/bin/env bash

# Replace the placeholders in /etc/tor/torrc with the value of the environment
# variables that we got over docker.
echo "Using OR_PORT=${OR_PORT}, PT_PORT=${PT_PORT}, and EMAIL=${EMAIL}."
sed -i -e "s/OR_PORT/${OR_PORT}/" /etc/tor/torrc
sed -i -e "s/PT_PORT/${PT_PORT}/" /etc/tor/torrc
sed -i -e "s/EMAIL/${EMAIL}/"     /etc/tor/torrc

echo "Starting tor."
tor -f /etc/tor/torrc
